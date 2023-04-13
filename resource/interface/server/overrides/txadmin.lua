if GetConvar('ox:txAdminOverrides', 'false') == 'true' then
    if GetConvar('txAdmin-hideDefaultAnnouncement', 'false') == 'true' then
        AddEventHandler('txAdmin:events:announcement', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:notify', -1, {
                id = 'txAdmin:playerDirectMessage',
                title = ('Server announcement by %s'):format(tx.author),
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
                title = ('Direct Message from %s'):format(tx.author),
                description = tx.message,
                duration = 5000
            })
        end)
    end

    if GetConvar('txAdmin-hideDefaultWarning', 'false') == 'true' then
        AddEventHandler('txAdmin:events:playerWarned', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:alertDialog', tx.target, {
                header = ('You have been warned by %s'):format(tx.author),
                content = ('%s  \nAction ID: %s'):format(tx.reason, tx.actionId),
                centered = true
            })
        end)
    end

    if GetConvar('txAdmin-hideDefaultScheduledRestartWarning', 'false') == 'true' then
        AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
            local tx = eventData
            TriggerClientEvent('ox_lib:notify', -1, {
                id = 'txAdmin:scheduledRestart',
                title = 'Scheduled Restart',
                description = tx.translatedMessage,
                duration = 5000
            })
        end)
    end
end
