


rmtMenuMain = {};
rmtMenuMain.modDirectory = g_currentModDirectory;

function rmtMenuMain:loadMap(n)
		g_currentMission.rmtMenu = {};
		
		g_currentMission.rmtMenu.background = createImageOverlay(rmtMenuMain.modDirectory.."overlay/backgroundOverlay.dds");
		g_currentMission.rmtMenu.button_normal = createImageOverlay(rmtMenuMain.modDirectory.."overlay/button_normal.dds");
		g_currentMission.rmtMenu.button_hover = createImageOverlay(rmtMenuMain.modDirectory.."overlay/button_hover.dds");
		g_currentMission.rmtMenu.button_active = createImageOverlay(rmtMenuMain.modDirectory.."overlay/button_active.dds");
		
		g_currentMission.rmtMenu.checkbox_unchecked = createImageOverlay(rmtMenuMain.modDirectory.."overlay/checkbox_unchecked.dds");
		g_currentMission.rmtMenu.checkbox_checked = createImageOverlay(rmtMenuMain.modDirectory.."overlay/checkbox_checked.dds");
		
end;

function rmtMenuMain:keyEvent(unicode, sym, modifier, isDown)
end;
function rmtMenuMain:update(dt)


end;
function rmtMenuMain:draw()
end;
function rmtMenuMain:deleteMap()
end;
function rmtMenuMain:mouseEvent(posX, posY, isDown, isUp, button)
end;

addModEventListener(rmtMenuMain);