LoadLevelMenu = LoadLevelMenu or class()
function LoadLevelMenu:init()
	local menu = BeardLibEditor.managers.Menu
	self._menu = menu:make_page("Levels")
	MenuUtils:new(self)
	local tabs = self:Group("Tabs", {align_method = "grid", use_as_menu = true, offset = 0})
	local loc = self:Toggle("Localized", callback(self, self, "load_levels", false), false, {size_by_text = true, group = tabs, color = tabs.marker_highlight_color, offset = 0})
	local tab_opt = {w = (tabs.w - loc.w) / 3, group = tabs, offset = 0, color = tabs.marker_highlight_color}
	self:Button("All", callback(self, self, "load_levels", "all"), tab_opt)
	self:Button("Vanilla", callback(self, self, "load_levels", "vanilla"), tab_opt)
	self:Button("Custom", callback(self, self, "load_levels", "custom"), tab_opt)
	local levels = self:Group("Levels", {align_method = "grid", use_as_menu = true})
	self:load_levels("all")
end

function LoadLevelMenu:load_levels(name)
	name = name or self._current
	self._menu:ClearItems("levels")
	local columns = 3
	local loc = self:GetItem("Localized")
	local levels = self:GetItem("Levels")
	for id, level in pairs(tweak_data.levels) do
		if level.world_name and (name == "all" or (name == "custom" and level.custom) or (name == "vanilla" and not level.custom)) then
			self._menu:Button({
				name = id,
	            w = levels.w / columns,
				text = loc:Value() and managers.localization:text(tostring(level.name_id)) or id,
				callback = callback(self, self, "load_level", id),
				label = "levels",
				group = levels
			})	
		end
	end
	self._current = name
end

function LoadLevelMenu:load_level(level_id)
    QuickMenu:new("Load level?", "",
        {[1] = {text = "Yes", callback = function()
        	Global.editor_mode = true
			MenuCallbackHandler:play_single_player()
			Global.game_settings.level_id = level_id
			Global.game_settings.mission = "none"
			Global.game_settings.difficulty = "normal"
			Global.game_settings.world_setting = nil
			MenuCallbackHandler:start_the_game()	
			BeardLibEditor.managers.Menu:set_enabled(false)
        end
    },[2] = {text = "No", is_cancel_button = true}}, true)
end