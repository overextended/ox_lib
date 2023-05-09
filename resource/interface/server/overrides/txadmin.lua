if GetConvar('ox:txAdminOverrides', 'false') == 'true' then
    if GetConvar('txAdmin-hideDefaultAnnouncement', 'false') == 'true' then
        AddEventHandler('txAdmin:events:announcement', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:notify', -1, {
                id = 'txAdmin:announcement',
                title = locale('txadmin_override_announcement', tx.author),
                description = tx.message,
                duration = 5000
            })
        end)
    end

    if GetConvar('txAdmin-hideDefaultDirectMessage', 'false') == 'true' then
        AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:notify', tx.target, {
                id = 'txAdmin:playerDirectMessage',
                title = locale('txadmin_override_dm', tx.author),
                description = tx.message,
                duration = 5000
            })
        end)
    end

    if GetConvar('txAdmin-hideDefaultWarning', 'false') == 'true' then
        AddEventHandler('txAdmin:events:playerWarned', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:alertDialog', tx.target, {
                header = locale('txadmin_override_warn', tx.author),
                content = locale('txadmin_override_warn_content', tx.reason, tx.actionId),
                centered = true
            })
        end)
    end

    if GetConvar('txAdmin-hideDefaultScheduledRestartWarning', 'false') == 'true' then
        AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:notify', -1, {
                id = 'txAdmin:scheduledRestart',
                title = locale('txadmin_override_scheduledrestart'),
                description = tx.translatedMessage,
                duration = 5000
            })
        end)
    end
end
