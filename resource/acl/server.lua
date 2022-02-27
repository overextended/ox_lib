local function allowAce(allow)
	return allow == false and 'deny' or 'allow'
end

function lib.addAce(principal, ace, allow)
	ExecuteCommand(('add_ace %s %s %s'):format(principal, ace, allowAce(allow)))
end

function lib.removeAce(principal, ace, allow)
	ExecuteCommand(('remove_ace %s %s %s'):format(principal, ace, allowAce(allow)))
end

function lib.addPrincipal(child, parent)
	ExecuteCommand(('add_principal %s %s'):format(child, parent))
end


function lib.removePrincipal(child, parent)
	ExecuteCommand(('remove_principal %s %s'):format(child, parent))
end
