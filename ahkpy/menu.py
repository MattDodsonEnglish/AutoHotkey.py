import dataclasses as dc
import uuid

from .flow import ahk_call
from .unset import UNSET


__all__ = [
    "Menu",
    "TrayMenu",
    "tray_menu",
]


@dc.dataclass(frozen=True)
class Menu:
    name: str
    __slots__ = ("name",)

    def __init__(self, name: str = None):
        if name is None:
            name = str(uuid.uuid4())
        object.__setattr__(self, "name", name.lower())

    def get_handle(self):
        return ahk_call("MenuGetHandle", self.name)

    def add(
        self, item_name, callback, *,
        priority=0, default=False, enabled=True, checked=False,
        radio=False, right=False, new_column=False, bar_column=False,
        icon=None, icon_number=None, icon_width=None,
    ):
        return self._insert_or_update(
            None, item_name, callback=callback,
            priority=priority, default=default, enabled=enabled, checked=checked,
            radio=radio, right=right, new_column=new_column, bar_column=bar_column,
            icon=icon, icon_number=icon_number, icon_width=icon_width,
        )

    def add_separator(self):
        return self._insert_or_update(None, None)

    def add_submenu(
        self, item_name, submenu, *,
        default=False, enabled=True, checked=False,
        radio=False, right=False, new_column=False, bar_column=False,
        icon=None, icon_number=None, icon_width=None,
    ):
        return self._insert_or_update(
            None, item_name, submenu=submenu,
            default=default, enabled=enabled, checked=checked,
            radio=radio, right=right, new_column=new_column, bar_column=bar_column,
            icon=icon, icon_number=icon_number, icon_width=icon_width,
        )

    def insert(
        self, insert_before, item_name=None, callback=None, *,
        priority=0, default=False, enabled=True, checked=False,
        radio=False, right=False, new_column=False, bar_column=False,
        icon=None, icon_number=None, icon_width=None,
    ):
        if insert_before is None:
            raise TypeError("insert_before must not be None")
        return self._insert_or_update(
            insert_before, item_name, callback=callback,
            priority=priority, default=default, enabled=enabled, checked=checked,
            radio=radio, right=right, new_column=new_column, bar_column=bar_column,
            icon=icon, icon_number=icon_number, icon_width=icon_width,
        )

    def insert_separator(self, insert_before):
        if insert_before is None:
            raise TypeError("insert_before must not be None")
        return self._insert_or_update(insert_before, None)

    def insert_submenu(
        self, insert_before, item_name, submenu, *,
        default=False, enabled=True, checked=False,
        radio=False, right=False, new_column=False, bar_column=False,
        icon=None, icon_number=None, icon_width=None,
    ):
        if insert_before is None:
            raise TypeError("insert_before must not be None")
        return self._insert_or_update(
            insert_before, item_name, submenu=submenu,
            default=default, enabled=enabled, checked=checked,
            radio=radio, right=right, new_column=new_column, bar_column=bar_column,
            icon=icon, icon_number=icon_number, icon_width=icon_width,
        )

    def update(
        self, item_name, *, new_name=UNSET, callback=None, submenu=None,
        priority=None, enabled=None, checked=None,
        radio=None, right=None, new_column=None, bar_column=None,
        icon=None, icon_number=None, icon_width=None,
    ):
        self._insert_or_update(
            item_name, new_name, callback=callback, submenu=submenu,
            update=True,
            priority=priority, enabled=enabled, checked=checked,
            radio=radio, right=right, new_column=new_column, bar_column=bar_column,
            icon=icon, icon_number=icon_number, icon_width=icon_width,
        )

    def _insert_or_update(
        self, item_name=None, new_name=UNSET, *, callback=None, submenu=None,
        update=False,
        priority=None, default=False, enabled=True, checked=False,
        radio=None, right=None, new_column=None, bar_column=None,
        icon=None, icon_number=None, icon_width=None,
    ):
        item_name = self._item_name(item_name)

        if submenu is not None:
            thing = f":{submenu.name}"
        elif callback is not None:
            # TODO: Pass Menu instance to callback.
            thing = callback
        else:
            thing = None

        option_list = []
        if priority is not None:
            option_list.append(f"P{priority}")
        if radio is not None:
            option_list.append(f"{'+' if radio else '-'}Radio")
        if right is not None:
            option_list.append(f"{'+' if right else '-'}Right")
        if new_column is not None:
            option_list.append(f"{'+' if new_column else '-'}Break")
        if bar_column is not None:
            option_list.append(f"{'+' if bar_column else '-'}BarBreak")
        option_str = " ".join(option_list)

        if update:
            if new_name is not UNSET:
                self.rename(item_name, new_name)
            # Update separately. If the menu item doesn't exist, setting the
            # options will fail.
            if option_str:
                self._call("Add", item_name, "", option_str)
            if thing is not None:
                self._call("Add", item_name, thing)
            if enabled:
                self.enable(item_name)
            elif enabled is not None:
                self.disable(item_name)
            if checked:
                self.check(item_name)
            elif checked is not None:
                self.uncheck(item_name)
            if icon:
                self.set_icon(item_name, icon, icon_number, icon_width)
        else:
            self._call("Insert", item_name, new_name, thing, option_str)
            if new_name:  # If not a separator
                if default:
                    self.set_default(new_name)
                if not enabled:
                    self.disable(new_name)
                if checked:
                    self.check(new_name)
                if icon:
                    self.set_icon(new_name, icon, icon_number, icon_width)
            return self

    def delete_item(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Delete", item_name)

    def delete_all_items(self):
        self._call("DeleteAll")

    def delete_menu(self):
        self._call("Delete")

    def rename(self, item_name, new_name=None):
        if item_name is not None:
            item_name = self._item_name(item_name)
        self._call("Rename", item_name, new_name)

    def check(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Check", item_name)

    def uncheck(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Uncheck", item_name)

    def toggle_check(self, item_name):
        item_name = self._item_name(item_name)
        self._call("ToggleCheck", item_name)

    def enable(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Enable", item_name)

    def disable(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Disable", item_name)

    def toggle_enable(self, item_name):
        item_name = self._item_name(item_name)
        self._call("ToggleEnable", item_name)

    def set_default(self, item_name):
        item_name = self._item_name(item_name)
        self._call("Default", item_name)

    def remove_default(self):
        self._call("NoDefault")

    def _remove_standard(self):
        self._call("NoStandard")

    def set_icon(self, item_name, filename, number=0, width=None):
        item_name = self._item_name(item_name)
        number = number or 0
        self._call("Icon", item_name, filename, number+1, width)

    def remove_icon(self, item_name):
        item_name = self._item_name(item_name)
        self._call("NoIcon", item_name)

    def show(self):
        # TODO: Coordinates
        self._call("Show")

    def set_color(self, color):
        self._call("Color", color)

    def _item_name(self, name):
        if isinstance(name, int):
            name = f"{name + 1}&"
        return name

    def _call(self, *args):
        # print(*map(repr, ("Menu", self.name, *args)))
        return ahk_call("Menu", self.name, *args)


class TrayMenu(Menu):
    __slots__ = ("name",)

    def __init__(self):
        super().__init__("tray")

    def set_tray_icon(self, filename, *, freeze=False):
        self._call("Icon", filename)

    def remove_tray_icon(self):
        self._call("NoIcon")

    def set_tip(self, text):
        self._call("Tip", text)

    def set_click(self, number):
        self._call("Click", number)


tray_menu = TrayMenu()