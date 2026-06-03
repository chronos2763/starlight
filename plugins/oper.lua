module = {user={}, oper={}, feedback={}, tick={}}

module.oper.b = function(word)
  if word[2] ~= author.nickname then
    irc:send('MODE ' .. config.channel .. ' +b ' .. word[2] .. CR)
    irc:send('KICK ' .. config.channel .. ' ' .. word[2] .. ' :' .. word[3] .. CR)
    irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
  end
end

module.oper.k = function(word)
  if word[2] ~= author.nickname then
    irc:send('KICK ' .. config.channel .. ' ' .. word[2] .. ' :' .. word[3] .. CR)
    irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
  end
end

module.oper.q = function(word)
  if word[2] ~= author.nickname then
    irc:send('MODE ' .. config.channel .. ' +q ' .. word[2] .. CR)
    irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
  end
end

module.oper.op = function(word)
  target = word[2] or author.nickname
  irc:send('MODE ' .. config.channel .. ' +o ' .. target .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

module.oper.deop = function(word)
  target = word[2] or author.nickname
  irc:send('MODE ' .. config.channel .. ' -o ' .. target .. CR)
  irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
end

return module
