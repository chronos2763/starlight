module = {user={}, oper={}, feedback={}, tick={}}
touchsave('quotesplugin')

module.oper.qadd = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  
  local quotes = savedata.quotesplugin.quotes
  quotes[#quotes + 1] = word[2]
  
  editsave('quotesplugin', 'quotes', quotes)
  irc:send(MSGHEAD .. 'Added quote #' .. #savedata.quotesplugin.quotes .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.oper.qgrab = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  
  local quotes = savedata.quotesplugin.quotes
  quotes[#quotes + 1] = '<' .. word[2] .. '> '.. last[word[2]]
  
  editsave('quotesplugin', 'quotes', quotes)
  irc:send(MSGHEAD .. 'Added quote #' .. #savedata.quotesplugin.quotes .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.oper.qset = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  
  local quotes = savedata.quotesplugin.quotes
  if not quotes[tonumber(word[2])] then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] That quote doesn\'t exist.' .. CR)
    return
  end
  
  quotes[tonumber(word[2])] = word[3]
  
  editsave('quotesplugin', 'quotes', quotes)
  irc:send(MSGHEAD .. 'Replaced quote #' .. word[2] .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.oper.qremove = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  
  local quotes = savedata.quotesplugin.quotes
  if not quotes[tonumber(word[2])] then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] That quote doesn\'t exist.' .. CR)
    return
  end
  
  table.remove(quotes, tonumber(word[2]))
  
  editsave('quotesplugin', 'quotes', quotes)
  irc:send(MSGHEAD .. 'Removed quote #' .. word[2] .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.oper.qclear = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  
  if last[author.nickname] ~= config.operfix .. 'qclear' then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] You are about to clear all quotes. To confirm this decision, resend the command once more.' .. CR)
    return
  end
  editsave('quotesplugin', 'quotes', {})
  irc:send(MSGHEAD .. 'Cleared all quotes.' .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.user.qget = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  local quotes = savedata.quotesplugin.quotes
  if not quotes[tonumber(word[2])] then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] That quote doesn\'t exist.' .. CR)
    return
  end
  
  irc:send(MSGHEAD .. 'Quote #' .. word[2] .. ': ' .. quotes[tonumber(word[2])] .. CR)
end

module.user.qrandom = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  local quotes = savedata.quotesplugin.quotes
  quotenum = math.random(1, #quotes)
  irc:send(MSGHEAD .. 'Quote #' .. quotenum .. ': ' .. quotes[quotenum] .. CR)
end

module.user.qcount = function(word)
  if not savedata.quotesplugin.quotes then editsave('quotesplugin', 'quotes', {}) end
  local quotes = savedata.quotesplugin.quotes
  irc:send(MSGHEAD .. 'There are currently ' .. #quotes .. ' quotes.' .. CR)
end

module.user.qhelp = function(word)
  irc:send(MSGHEAD .. 'qadd - add a quote (chanop only)' .. CR)
  irc:send(MSGHEAD .. 'qset (quote #) - replace a quote (chanop only)' .. CR)
  irc:send(MSGHEAD .. 'qgrab (user) - take a user\'s last message and add it as a quote (chanop only)' .. CR)
  irc:send(MSGHEAD .. 'qremove (quote #) - remove a quote (chanop only)' .. CR)
  irc:send(MSGHEAD .. 'qclear - clear all quotes (chanop only)' .. CR)
  irc:send(MSGHEAD .. 'qget (quote #) - see a quote' .. CR)
  irc:send(MSGHEAD .. 'qrandom - see a random quote' .. CR)
  irc:send(MSGHEAD .. 'qcount - see how many quotes there are' .. CR)
  irc:send(MSGHEAD .. 'qhelp - see these messages' .. CR)
end

return module
