UpperMenu = UpperMenu or class(EditorPart)
function UpperMenu:get_menu_h() return self._menu:Panel():parent():h() - self._menu.h - 1 end
function UpperMenu:init(parent, menu)
    self._parent = parent
    local normal = not Global.editor_safe_mode
    self._tabs = {
        {name = "world", rect = {135, 271, 115, 115}},
        {name = "static", rect = {256, 262, 115, 115}, enabled = normal},
        {name = "env", rect = {15, 267, 115, 115}},
        {name = "opt", rect = {385, 385, 115, 115}},
        {name = "save", rect = {260, 385, 115, 115}, callback = ClassClbk(self, "save"), enabled = normal},
        {name = "move_widget_toggle", rect = {9, 377, 115, 115}, callback = ClassClbk(self, "toggle_widget", "move"), enabled = normal and self._parent._has_fix},
        {name = "rotation_widget_toggle", rect = {137, 383, 115, 115}, callback = ClassClbk(self, "toggle_widget", "rotation"), enabled = normal and self._parent._has_fix},
    }
    local w = BLE.Options:GetValue("MapEditorPanelWidth")
    self._menu = menu:Menu({
        name = "upper_menu",
        background_color = BeardLibEditor.Options:GetValue("BackgroundColor"),
        accent_color = BeardLibEditor.Options:GetValue("AccentColor"),
        w = w,
        h = 300 / #self._tabs - 4,
        auto_foreground = true,
        offset = 0,
        align_method = "grid",
        scrollbar = false,
        visible = true,
    })
    local s = 300 / #self._tabs
    self._line = self._menu:Panel():rect({
        color = self._menu.accent_color,
        layer = 10,
        x = -s,
        y = self._menu:H() - 2,
        w = s,
        h = 2,
    })
    ItemExt:add_funcs(self)
end

function UpperMenu:build_tabs()
    for _, tab in pairs(self._tabs) do
        local s = self._menu:H()
        local t = self:Tab(tab.name, "textures/editor_icons_df", tab.rect, tab.callback, s, tab.enabled)
        if tab.name:match("_widget_toggle") then
            self:update_toggle(t)
        end
    end
end

function UpperMenu:Tab(name, texture, texture_rect, clbk, s, enabled)
    return self._menu:ImageButton({
        name = name,
        texture = texture,
        texture_rect = texture_rect,
        is_page = not clbk,
        enabled = enabled,
        cannot_be_enabled = enabled == false,
        on_callback = ClassClbk(self, "select_tab", clbk or false),
        disabled_alpha = 0.2,
        w = 300 / #self._tabs,
        h = self._menu:H(),
        icon_w = s - 12,
        icon_h = s - 12,      
    })    
end

function UpperMenu:select_tab(clbk, item)
    if clbk then
        clbk(item)
    else
        self:Switch(BeardLibEditor.Utils:GetPart(item.name))
    end
end

function UpperMenu:is_tab_enabled(manager)
    local item = self:GetItem(manager)
    if item then
        return item:Enabled()
    end
    return true
end

function UpperMenu:set_tabs_enabled(enabled)
    for manager in pairs(self._parent.parts) do
        local item = self:GetItem(manager)
        if item and not item.cannot_be_enabled then
            item:SetEnabled(enabled)
        end
    end
end

function UpperMenu:toggle_widget(name, item)
    if ctrl() then return end
    item = item or self:GetItem(name.."_widget_toggle")
    local menu = item.parent
    if not item.enabled then return end

    self._parent["toggle_"..name.."_widget"](self._parent)
    self._parent:use_widgets(self._parent:selected_unit() ~= nil)
    self:update_toggle(item)
end

function UpperMenu:update_toggle(item)
    local name = item.name:gsub("_widget_toggle", "")
    item.enabled_alpha = self._parent[name.."_widget_enabled"](self._parent) and 1 or 0.5
    item:SetEnabled(item.enabled)
end

function UpperMenu:Switch(manager, no_anim)
    local item = self:GetItem(manager.manager_name)
    local menu = manager._menu

    if self._parent._current_menu then
        self._parent._current_menu:SetVisible(false)
    end
    self._parent._current_menu = menu
    self._parent._current_menu_name = item.name
    menu:SetVisible(true)
    self:move_line_to(item, no_anim)
end

function UpperMenu:move_line_to(item, no_anim)
    if not alive(item) then
        return
    end
    if no_anim then
        self._line:stop()
        self._line:set_x(item:X())
    else
        play_value(self._line, "x", item:X())
    end
end

function UpperMenu:save()
    self._parent:Log("Saving Map..")
    BeardLibEditor.Utils:GetPart("opt"):save()
end