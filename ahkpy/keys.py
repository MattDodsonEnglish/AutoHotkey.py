import inspect
import threading
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Callable, Union

import _ahk  # noqa

from .exceptions import Error

__all__ = [
    "Hotkey",
    "HotkeyContext",
    "Hotstring",
    "SendMode",
    "get_key_state",
    "get_physical_key_state",
    "hotkey",
    "hotstring",
    "is_key_toggled",
    "key_wait_pressed",
    "key_wait_released",
    "remap_key",
    "reset_hotstring",
    "send",
    "set_caps_lock_state",
    "set_num_lock_state",
    "set_scroll_lock_state",
]


class SendMode:
    INPUT = "input"
    PLAY = "play"
    EVENT = "event"


def get_key_state(key_name):
    return _get_key_state(key_name)


def get_physical_key_state(key_name):
    return _get_key_state(key_name, "P")


def is_key_toggled(key_name):
    if key_name.lower() not in ("capslock", "numlock", "scrolllock", "insert", "ins"):
        raise ValueError("key_name must be one of CapsLock, NumLock, ScrollLock, or Insert")
    return _get_key_state(key_name, "T")


def _get_key_state(key_name, mode=None):
    result = _ahk.call("GetKeyState", key_name, mode)
    if result == "":
        raise ValueError("key_name is invalid or the state of the key could not be determined")
    return bool(result)


def set_caps_lock_state(state):
    _set_key_state("SetCapsLockState", state)


def set_num_lock_state(state):
    _set_key_state("SetNumLockState", state)


def set_scroll_lock_state(state):
    _set_key_state("SetScrollLockState", state)


def _set_key_state(cmd, state):
    if isinstance(state, str) and state.lower() in ("always_on", "alwayson"):
        state = "AlwaysOn"
    elif isinstance(state, str) and state.lower() in ("always_off", "alwaysoff"):
        state = "AlwaysOff"
    elif state:
        state = "On"
    else:
        state = "Off"
    _ahk.call(cmd, state)


@dataclass(frozen=True)
class BaseHotkeyContext:
    _lock = threading.RLock()

    # XXX: Consider adding context options: MaxThreadsBuffer,
    # MaxThreadsPerHotkey, and InputLevel.

    def hotkey(
        self,
        key_name: str,
        func: Callable = None,
        *,
        buffer=False,
        priority=0,
        max_threads=1,
        input_level=0,
    ):
        if key_name == "":
            raise Error("invalid key name")

        def hotkey_decorator(func):
            if not callable(func):
                raise TypeError(f"object {func!r} must be callable")

            hk = Hotkey(key_name, context=self)
            hk.update(
                func=func,
                buffer=buffer,
                priority=priority,
                max_threads=max_threads,
                input_level=input_level,
            )
            hk.enable()
            return hk

        if func is None:
            # XXX: Consider implementing decorator chaining, e.g.:
            #
            #     @ahk.hotkey("F11")
            #     @ahk.hotkey("F12")
            #     def func():
            #         print("F11 or F12 was pressed")
            return hotkey_decorator

        # TODO: Handle case when func == "AltTab" or other substitutes.
        # TODO: Hotkey command may set ErrorLevel. Raise an exception.

        return hotkey_decorator(func)

    def hotstring(
        self,
        string: str,
        replacement: Union[str, Callable] = None,
        *,
        case_sensitive=False,
        conform_to_case=True,
        replace_inside_word=False,
        wait_for_end_char=True,
        omit_end_char=False,
        backspacing=True,
        priority=0,
        text=False,
        mode=None,
        key_delay=-1,
        reset_recognizer=False,
    ):
        # TODO: Implement setting global options.
        def hotstring_decorator(replacement):
            hs = Hotstring(string, case_sensitive, replace_inside_word, context=self)
            hs.update(
                replacement=replacement,
                conform_to_case=conform_to_case,
                wait_for_end_char=wait_for_end_char,
                omit_end_char=omit_end_char,
                backspacing=backspacing,
                priority=priority,
                text=text,
                mode=mode,
                key_delay=key_delay,
                reset_recognizer=reset_recognizer,
            )
            # Enable the hotstring in case another hotstring with the same
            # 'string' existed before, but was disabled.
            hs.enable()
            return hs

        if replacement is None:
            return hotstring_decorator
        return hotstring_decorator(replacement)

    @contextmanager
    def _manager(self):
        # I don't want to make BaseHotkeyContext a Python context manager,
        # because the end users will be tempted to use it as such, e.g:
        #
        #     with hotkey_context(lambda: ...):
        #         hotkey(...)
        #
        # This approach has a number of issues that can be mitigated, but better
        # be avoided:
        #
        # 1. Current context must be stored in a thread-local storage in order
        #    to be referenced by hotkey(). This can be solved by returning the
        #    context as `with ... as ctx`.
        # 2. Nested contexts become possible, but implementing them is not
        #    trivial.
        #
        # Instead, the following is the chosen way to use the hotkey contexts:
        #
        #     ctx = hotkey_context(lambda: ...)
        #     ctx.hotkey(...)

        with BaseHotkeyContext._lock:
            self._enter()
            yield
            self._exit()

    def _enter(self):
        pass

    def _exit(self):
        pass


default_context = BaseHotkeyContext()
hotkey = default_context.hotkey
hotstring = default_context.hotstring


@dataclass(frozen=True)
class HotkeyContext(BaseHotkeyContext):
    predicate: Callable

    def __init__(self, predicate):
        signature = inspect.signature(predicate)
        if len(signature.parameters) == 0:
            def wrapper(*args):
                return bool(predicate())
        else:
            def wrapper(*args):
                return bool(predicate(*args))

        object.__setattr__(self, "predicate", wrapper)

    def _enter(self):
        _ahk.call("HotkeyContext", self.predicate)

    def _exit(self):
        _ahk.call("HotkeyExitContext")


@dataclass(frozen=True)
class Hotkey:
    key_name: str
    context: BaseHotkeyContext

    # I decided not to have 'func' and hotkey options as fields, because:
    #
    # 1. There's no way to get the option's value from an existing Hotkey. This
    #    means that the option must be stored in the Python Hotkey object.
    # 2. There's always a chance of setting an option in AHK but failing to
    #    store it in Python. Likewise, an option may be stored in Python, but
    #    not set in AHK yet.
    # 3. An option may be changed from the AHK side. In this case the value
    #    stored in the Python Hotkey object becomes absolete and misleading.

    def enable(self):
        with self.context._manager():
            _ahk.call("HotkeySpecial", self.key_name, "On")

    def disable(self):
        with self.context._manager():
            _ahk.call("HotkeySpecial", self.key_name, "Off")

    def toggle(self):
        with self.context._manager():
            _ahk.call("HotkeySpecial", self.key_name, "Toggle")

    def update(self, *, func=None, buffer=None, priority=None, max_threads=None, input_level=None):
        options = []

        if buffer:
            options.append("B")
        elif buffer is not None:
            options.append("B0")

        if priority is not None:
            options.append(f'P{priority}')

        if max_threads is not None:
            options.append(f"T{max_threads}")

        if input_level is not None:
            options.append(f"I{input_level}")

        option_str = "".join(options)

        context_hash = hash(self.context)
        with self.context._manager():
            _ahk.call("Hotkey", context_hash, self.key_name, func or "", option_str)


@dataclass(frozen=True)
class Hotstring:
    string: str
    case_sensitive: bool
    replace_inside_word: bool
    context: BaseHotkeyContext

    # There are no 'replacement' and option fields in Hotstring object. See the
    # reasoning in the Hotkey class.

    # Case sensitivity and conformity transitions:
    #     CO <-> C1
    #     C1 <-- C --> C0

    def __post_init__(self):
        if hasattr(self.string, 'lower') and not self.case_sensitive:
            object.__setattr__(self, "string", self.string.lower())

    def disable(self):
        with self.context._manager():
            _ahk.call("Hotstring", f":{self._id_options()}:{self.string}", "", "Off")

    def enable(self):
        with self.context._manager():
            _ahk.call("Hotstring", f":{self._id_options()}:{self.string}", "", "On")

    def toggle(self):
        with self.context._manager():
            _ahk.call("Hotstring", f":{self._id_options()}:{self.string}", "", "Toggle")

    def _id_options(self):
        case_option = "C" if self.case_sensitive else ""
        replace_inside_option = "?" if self.replace_inside_word else "?0"
        return f"{case_option}{replace_inside_option}"

    def update(
        self, *, replacement=None, conform_to_case=None, wait_for_end_char=None, omit_end_char=None, backspacing=None,
        priority=None, text=None, mode=None, key_delay=None, reset_recognizer=None,
    ):
        options = []

        if self.case_sensitive:
            options.append("C")
        elif conform_to_case:
            options.append("C0")
        elif conform_to_case is not None:
            options.append("C1")

        if self.replace_inside_word:
            options.append("?")
        else:
            options.append("?0")

        if wait_for_end_char is False:
            options.append("*")
        elif omit_end_char:
            options.append("*0")
            options.append("O")
        else:
            if wait_for_end_char:
                options.append("*0")
            if omit_end_char is False:
                options.append("O0")

        if backspacing:
            options.append("B")
        elif backspacing is not None:
            options.append("B0")

        if key_delay is not None:
            if key_delay > 0:
                key_delay = int(key_delay * 1000)
            options.append(f"K{key_delay}")

        if priority is not None:
            options.append(f"P{priority}")

        if text:
            options.append("T")
        elif text is not None:
            options.append("T0")

        # TODO: The hotstring is not replaced when the mode is set to Input
        # explicitly.
        if mode is not None:
            mode = mode.lower()
        if mode == SendMode.INPUT:
            options.append("SI")
        elif mode == SendMode.PLAY:
            options.append("SP")
        elif mode == SendMode.EVENT:
            options.append("SE")

        if reset_recognizer:
            options.append("Z")
        elif reset_recognizer is not None:
            options.append("Z0")

        option_str = "".join(options)

        with self.context._manager():
            # TODO: Handle changing replacement func.
            _ahk.call("Hotstring", f":{option_str}:{self.string}", replacement or "")


def reset_hotstring():
    _ahk.call("Hotstring", "Reset")


# TODO: Implement Hotstring, MouseReset and Hotstring, EndChars.


def key_wait_pressed(key_name, logical_state=False, timeout=None) -> bool:
    return _key_wait(key_name, down=True, logical_state=logical_state, timeout=timeout)


def key_wait_released(key_name, logical_state=False, timeout=None) -> bool:
    return _key_wait(key_name, down=False, logical_state=logical_state, timeout=timeout)


def _key_wait(key_name, down=False, logical_state=False, timeout=None) -> bool:
    options = []
    if down:
        options.append("D")
    if logical_state:
        options.append("L")
    if timeout is not None:
        options.append(f"T{timeout}")
    timed_out = _ahk.call("KeyWait", str(key_name), "".join(options))
    return not timed_out


def remap_key(origin_key, destination_key):
    # TODO: Handle LCtrl as the origin key.
    # TODO: Handle remapping keyboard key to a mouse button.
    # TODO: Implement context-specific remapping.
    @hotkey(f"*{origin_key}")
    def wildcard_origin():
        send("{Blind}{%s DownR}" % destination_key)

    @hotkey(f"*{origin_key} Up")
    def wildcard_origin_up():
        send("{Blind}{%s Up}" % destination_key)

    return RemappedKey(wildcard_origin, wildcard_origin_up)


@dataclass(frozen=True)
class RemappedKey:
    wildcard_origin: Hotkey
    wildcard_origin_up: Hotkey

    def enable(self):
        self.wildcard_origin.enable()
        self.wildcard_origin_up.enable()

    def disable(self):
        self.wildcard_origin.disable()
        self.wildcard_origin_up.disable()

    def toggle(self):
        self.wildcard_origin.toggle()
        self.wildcard_origin_up.toggle()


send_lock = threading.RLock()


def send(keys, *, mode=SendMode.INPUT, level=0):
    # TODO: Sending "{U+0009}" and "\u0009" gives different results depending on
    # how tabs are handled in the application.

    if mode == SendMode.INPUT:
        cmd = "SendInput"
    elif mode == SendMode.PLAY:
        cmd = "SendPlay"
    elif mode == SendMode.EVENT:
        cmd = "SendEvent"
    else:
        raise ValueError(f"unknown send mode: {mode!r}")

    with send_lock:
        _send_level(level)
        _ahk.call(cmd, keys)


def _send_level(level: int):
    if not 0 <= level <= 100:
        raise ValueError("level must be between 0 and 100")
    _ahk.call("SendLevel", int(level))
