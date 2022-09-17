---@class TextUIOptions
---@field position? 'right-center' | 'left-center' | 'top-center';
---@field icon? string;
---@field iconColor? string;
---@field style? string;

---@param text string
---@param options TextUIOptions
function lib.showTextUI(text, options)
    if not options then options = {} end
    options.text = text
    SendNUIMessage({
        action = 'textUi',
        data = options
    })
end

function lib.hideTextUI()
    SendNUIMessage({
        action = 'textUiHide'
    })
end