import subprocess
import time
from dataclasses import FrozenInstanceError
from functools import partial

import pytest

import ahk


def test_windows(child_ahk):
    def windows():
        import ahk
        import sys

        ahk.hotkey("F24", sys.exit)

        @ahk.set_timer(countdown=0.1)
        def win1():
            ahk.message_box("win1", title="win1")

        @ahk.set_timer(countdown=0.2)
        def win2():
            ahk.message_box("win2", title="win2")

        ahk.sleep(1)
        sys.exit()

    assert ahk.windows.get_active()

    child_ahk.popen_code(windows)
    ahk.set_win_delay(None)

    assert repr(ahk.windows) == "Windows()"

    msg_boxes = ahk.windows.filter(exe="AutoHotkey.exe")
    assert repr(msg_boxes) == "Windows(exe='AutoHotkey.exe')"

    wait_result = msg_boxes.wait(timeout=1)
    assert wait_result is not None
    assert isinstance(wait_result, ahk.Window)
    assert msg_boxes.wait(title="win1", timeout=1).title == "win1"
    assert msg_boxes.wait(title="win2", timeout=1).title == "win2"

    assert len(msg_boxes) == 2
    ahk_window_list = list(msg_boxes)
    assert ahk_window_list != []
    top = msg_boxes.first()
    assert ahk_window_list[0] == top
    assert ahk_window_list[-1] == msg_boxes.last()
    assert repr(top) == f"Window(id={top.id})"

    assert len(msg_boxes.filter(title="win2")) == 1
    assert msg_boxes.filter(title="win2").first().title == "win2"
    assert len(msg_boxes.exclude(title="win2")) == 1
    assert msg_boxes.exclude(title="win2").first().title == "win1"

    assert all(mb.is_restored for mb in msg_boxes)
    msg_boxes.minimize_all()
    assert all(mb.is_minimized for mb in msg_boxes)
    msg_boxes.maximize_all()
    assert all(mb.is_maximized for mb in msg_boxes)
    msg_boxes.restore_all()
    assert all(mb.is_restored for mb in msg_boxes)

    win1 = msg_boxes.first(title="win1")
    assert win1
    assert win1.exists

    win2 = msg_boxes.first(title="win2")
    assert win1.activate(timeout=1)
    assert not win2.is_active

    assert len(msg_boxes) == 2
    win1.bring_to_top()
    assert msg_boxes.first() == win1
    win1.send_to_bottom()
    assert msg_boxes.last() == win1
    win1.bring_to_top()
    assert msg_boxes.first() == win1

    msg_boxes.minimize()
    assert win1.is_minimized
    msg_boxes.activate(timeout=1)
    assert win2.is_active
    win1.restore()
    msg_boxes.maximize()
    assert win1.is_maximized
    win1.restore()
    ahk.detect_hidden_windows(True)
    msg_boxes.hide()
    assert not win1.is_visible
    win1.show()
    ahk.detect_hidden_windows(False)
    msg_boxes.pin_to_top()
    assert win1.always_on_top
    msg_boxes.unpin_from_top()
    assert not win1.always_on_top
    msg_boxes.toggle_always_on_top()
    assert win1.always_on_top
    msg_boxes.disable()
    assert not win1.is_enabled
    msg_boxes.enable()
    assert win1.is_enabled
    win1.activate(timeout=1)
    msg_boxes.close()
    assert win1.wait_close(timeout=1)

    assert msg_boxes.wait_close(timeout=0.1) is False
    msg_boxes.close_all()
    assert msg_boxes.wait_close() is True
    assert not msg_boxes.exist()

    ahk.send("{F24}")


def test_window(child_ahk, detect_hidden_windows):
    def window():
        import ahk
        import sys

        ahk.hotkey("F24", sys.exit)
        ahk.message_box("win1", title="win1")

    proc = child_ahk.popen_code(window)
    ahk.set_win_delay(None)

    nonexistent_window = ahk.Window(99999)
    assert not nonexistent_window.exists

    win1 = ahk.windows.wait(title="win1", exe="AutoHotkey.exe")
    assert win1
    assert hash(win1) == hash(ahk.Window(win1.id))
    with pytest.raises(FrozenInstanceError):
        win1.id = 0

    _, _, width, height = win1.rect
    x, y = win1.position
    win1.y += 100
    assert win1.y == y + 100
    win1.x = win1.y
    assert win1.x == win1.y
    win1.height += 100
    assert win1.height == height + 100
    win1.height = win1.width
    assert win1.height == win1.width

    assert win1.title == "win1"
    win1.title = "win111"
    assert win1.title == "win111"

    assert win1.pid > 0
    assert nonexistent_window.pid is None

    assert win1.process_name == "AutoHotkey.exe"
    assert nonexistent_window.process_name is None

    assert win1.process_path == proc.args[0]
    assert nonexistent_window.process_path is None

    assert nonexistent_window.opacity is None
    assert win1.opacity is None
    win1.opacity = 128
    assert win1.opacity == 128
    win1.opacity = None
    assert win1.opacity is None

    assert win1.transparent_color is None
    win1.transparent_color = (255, 255, 255)
    assert win1.transparent_color == (255, 255, 255)
    win1.transparent_color = None
    assert win1.transparent_color is None

    assert win1.is_visible
    win1.hide()
    assert win1.is_visible is False
    win1.show()
    assert win1.is_visible

    assert nonexistent_window.is_minimized is None
    assert nonexistent_window.is_maximized is None
    assert nonexistent_window.is_restored is None

    win1.maximize()
    assert win1.is_maximized
    win1.restore()
    assert win1.is_restored
    win1.minimize()
    assert win1.is_minimized
    win1.toggle_minimized()
    assert win1.is_restored
    assert win1.wait_active() is True
    assert win1.wait_close(timeout=0.1) is False

    assert win1.is_enabled
    win1.disable()
    assert win1.is_enabled is False
    win1.enable()
    assert win1.is_enabled
    win1.redraw()

    assert win1.always_on_top is False
    win1.toggle_always_on_top()
    assert win1.always_on_top is True
    win1.always_on_top = False
    assert win1.always_on_top is False
    win1.always_on_top = True
    assert win1.always_on_top is True
    win1.unpin_from_top()
    assert win1.always_on_top is False

    assert isinstance(win1.style, ahk.WindowStyle)
    assert ahk.WindowStyle.POPUPWINDOW in win1.style

    assert isinstance(win1.ex_style, ahk.ExWindowStyle)
    assert win1.ex_style > 0

    ahk.send("{F24}")


def test_status_bar(request):
    notepad_proc = subprocess.Popen(["notepad.exe"])
    request.addfinalizer(notepad_proc.terminate)
    notepad_win = ahk.windows.wait(pid=notepad_proc.pid)
    assert notepad_win

    ahk.sleep(0.2)
    assert "Ln 1, Col 1" in notepad_win.get_status_bar_text(2)

    notepad_win.send("q")
    ahk.sleep(0)
    assert "Ln 1, Col 2" in notepad_win.get_status_bar_text(2)

    ahk.set_timer(partial(notepad_win.send, "q"), countdown=0.5)
    assert notepad_win.wait_status_bar("  Ln 1, Col 3", part=2, timeout=1) is True
    assert notepad_win.get_status_bar_text(2) == "  Ln 1, Col 3"

    notepad_proc.terminate()


def test_window_context(child_ahk):
    def code():
        import ahk
        import sys
        ahk.hotkey("F24", sys.exit)
        ahk.hotkey("F13", lambda: ahk.message_box("General"))
        with ahk.windows.window_context(exe="AutoHotkey.exe", text="General"):
            ahk.hotkey("F13", lambda: ahk.message_box("Context-specific"))
        print("ok00")

    child_ahk.popen_code(code)
    child_ahk.wait(0)
    ahk.set_win_delay(None)

    general_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="General")
    context_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Context-specific")

    assert not general_windows.exist()
    ahk.send("{F13}")
    assert general_windows.wait(timeout=1)
    assert not context_windows.exist()

    assert general_windows.exist()
    ahk.send("{F13}")
    assert context_windows.wait(timeout=1)

    ahk.send("{F24}")


def test_active_window_context(child_ahk):
    def code():
        import ahk
        import sys
        ahk.hotkey("F24", sys.exit)
        ahk.hotkey("F13", lambda: ahk.message_box("General"), max_threads=2)
        with ahk.windows.active_window_context(exe="AutoHotkey.exe", text="General"):
            ahk.hotkey("F13", lambda: ahk.message_box("Context-specific"))
        print("ok00")

    child_ahk.popen_code(code)
    child_ahk.wait(0)
    ahk.set_win_delay(None)

    general_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="General")
    context_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Context-specific")

    assert not general_windows.exist()
    ahk.send("{F13}")
    assert general_windows.wait(timeout=1)
    assert not context_windows.exist()

    assert general_windows.get_active()
    ahk.send("{F13}")
    assert context_windows.wait(timeout=1)
    assert len(general_windows) == 1

    assert general_windows.exist()
    assert not general_windows.get_active()
    ahk.send("{F13}")
    assert_equals_eventually(general_windows.__len__, 2)

    ahk.send("{F24}")


def test_exclude_window_context(child_ahk):
    def code():
        import ahk
        import sys
        ahk.hotkey("F24", sys.exit)
        ahk.hotkey("F13", lambda: ahk.message_box("General"), max_threads=2)
        ahk.hotkey("F14", lambda: ahk.message_box("Extra"))
        with ahk.windows.filter(exe="AutoHotkey.exe").exclude(text="General").window_context():
            # If there are any AutoHotkey windows beside General.
            ahk.hotkey("F13", lambda: ahk.message_box("Context-specific"))
        print("ok00")

    child_ahk.popen_code(code)
    child_ahk.wait(0)
    ahk.set_win_delay(None)

    general_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="General")
    non_general_windows = ahk.windows.filter(exe="AutoHotkey.exe").exclude(text="General")
    extra_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Extra")
    context_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Context-specific")

    assert not non_general_windows.exist()
    ahk.send("{F13}")
    assert general_windows.wait(timeout=1)
    assert not context_windows.exist()

    ahk.send("{F14}")
    assert extra_windows.wait(timeout=1)

    assert non_general_windows.exist()
    ahk.send("{F13}")
    assert context_windows.wait(timeout=1)

    ahk.send("{F24}")


def test_exclude_active_window_context(child_ahk):
    def code():
        import ahk
        import sys
        ahk.hotkey("F24", sys.exit)
        ahk.hotkey("F13", lambda: ahk.message_box("General"), max_threads=3)
        ahk.hotkey("F14", lambda: ahk.message_box("Extra"))
        with ahk.windows.filter(exe="AutoHotkey.exe").exclude(text="General").active_window_context():
            # If there are any active AutoHotkey windows beside General.
            ahk.hotkey("F13", lambda: ahk.message_box("Context-specific"))
        print("ok00")

    child_ahk.popen_code(code)
    child_ahk.wait(0)
    ahk.set_win_delay(None)

    general_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="General")
    non_general_windows = ahk.windows.filter(exe="AutoHotkey.exe").exclude(text="General")
    extra_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Extra")
    context_windows = ahk.windows.filter(exe="AutoHotkey.exe", text="Context-specific")

    assert not non_general_windows.exist()
    ahk.send("{F13}")
    assert general_windows.wait(timeout=1)
    assert not context_windows.exist()

    ahk.send("{F14}")
    assert extra_windows.wait(timeout=1)

    assert non_general_windows.get_active()
    ahk.send("{F13}")
    assert context_windows.wait(timeout=1)

    assert context_windows.close_all(timeout=1)
    assert general_windows.activate(timeout=1)
    assert non_general_windows.exist()
    assert not non_general_windows.get_active()
    ahk.send("{F13}")
    assert_equals_eventually(general_windows.__len__, 2)

    ahk.send("{F24}")


def assert_equals_eventually(func, expected, timeout=1):
    stop = time.perf_counter() + timeout
    while time.perf_counter() < stop:
        actual = func()
        if actual == expected:
            return
        ahk.sleep(0.01)
    assert actual == expected


# TODO: Write nonexistent/inactive window context tests.