module = {user={}, oper={}, feedback={}}

module.user.test = function(word)
  irc:send(MSGHEAD .. 'first arg: ' .. word[2] .. CR)
end

return module
