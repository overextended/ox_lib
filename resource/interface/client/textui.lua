---@class TextUIOptions
---@field position? 'right-center' | 'left-center' | 'top-center';
---@field icon? string;
---@field iconColor? string;
---@field style? string;

local isOpen = false

---@param text string
---@param options? TextUIOptions
function lib.showTextUI(text, options)
    if not options then options = {} end
    options.text = text
    SendNUIMessage({
        action = 'textUi',
        data = options
    })
    isOpen = true
end

function lib.hideTextUI()
    SendNUIMessage({
        action = 'textUiHide'
    })
    isOpen = false
end

---@return boolean
function lib.isTextUIOpen()
    return isOpen
end
