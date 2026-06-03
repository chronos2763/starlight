module = {user={}, oper={}, feedback={}, tick={}}
touchsave('karmaplugin')

module.feedback.main = function(word)
  if #word == 1 then
    if word[1]:sub(-2, -1) == '++' then
      if word[1]:sub(1,-3) ~= author.nickname then
        if not savedata.karmaplugin[word[1]:sub(1,-3)] then editsave('karmaplugin', word[1]:sub(1,-3), {0, 0, {given_pos={}, given_neg={}}}) end

        local userkarma = savedata.karmaplugin[word[1]:sub(1,-3)]
        if not findbyvalue(userkarma[3].given_pos, author.nickname) then
          userkarma[1] = userkarma[1] + 1
          table.insert(userkarma[3].given_pos, author.nickname)

          if findbyvalue(userkarma[3].given_neg, author.nickname) then
            table.remove(userkarma[3].given_neg, findbyvalue(userkarma[3].given_neg, author.nickname))
            userkarma[2] = userkarma[2] - 1
          end

          editsave('karmaplugin', word[1]:sub(1,-3), userkarma)

          irc:send(MSGHEAD .. word[1]:sub(1,-3) .. ': +' .. userkarma[1] .. ', -' .. userkarma[2] .. ' = ' .. userkarma[1] - userkarma[2] .. CR)
        else
          irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] You\'ve already given +karma to that user.' .. CR)
        end
      else
        irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] You can\'t vote on yourself.' .. CR)
      end
    elseif word[1]:sub(-2, -1) == '--' then
      if word[1]:sub(1,-3) ~= author.nickname then
        if not savedata.karmaplugin[word[1]:sub(1,-3)] then editsave('karmaplugin', word[1]:sub(1,-3), {0, 0, {given_pos={}, given_neg={}}}) end
        local userkarma = savedata.karmaplugin[word[1]:sub(1,-3)]

        if not findbyvalue(userkarma[3].given_neg, author.nickname) then
          userkarma[2] = userkarma[2] + 1
          table.insert(userkarma[3].given_neg, author.nickname)

          if findbyvalue(userkarma[3].given_pos, author.nickname) then
            table.remove(userkarma[3].given_pos, findbyvalue(userkarma[3].given_pos, author.nickname))
            userkarma[1] = userkarma[1] - 1
          end

          editsave('karmaplugin', word[1]:sub(1,-3), userkarma)

          irc:send(MSGHEAD .. word[1]:sub(1,-3) .. ': +' .. userkarma[1] .. ', -' .. userkarma[2] .. ' = ' .. userkarma[1] - userkarma[2] .. CR)
        else
          irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] You\'ve already given -karma to that user.' .. CR)
        end
      else
        irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] ...And why do you think I would let you do that? (You can\'t vote on yourself.)' .. CR)
      end
    end
  end
end

module.user.score = function(word)
  local userkarma = savedata.karmaplugin[word[2]]

  if not userkarma then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] That user doesn\'t have any karma associated with them.' .. CR)
    return
  end

  irc:send(MSGHEAD .. word[2] .. ': +' .. userkarma[1] .. ', -' .. userkarma[2] .. ' = ' .. userkarma[1] - userkarma[2] .. CR)
end

module.user.rmvote = function(word)
  local userkarma = savedata.karmaplugin[word[2]]

  if not userkarma then
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] That user doesn\'t have any karma associated with them.' .. CR)
    return
  end

  if findbyvalue(userkarma[3].given_neg, author.nickname) then
    table.remove(userkarma[3].given_neg, findbyvalue(userkarma[3].given_neg, author.nickname))
    userkarma[2] = userkarma[2] - 1
  elseif findbyvalue(userkarma[3].given_pos, author.nickname) then
    table.remove(userkarma[3].given_pos, findbyvalue(userkarma[3].given_pos, author.nickname))
    userkarma[1] = userkarma[1] - 1
  else
    irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] You haven\'t casted a vote on that user.' .. CR)
  end
  editsave('karmaplugin', word[2], userkarma)
  irc:send(MSGHEAD .. word[2] .. ': +' .. userkarma[1] .. ', -' .. userkarma[2] .. ' = ' .. userkarma[1] - userkarma[2] .. CR)
end

return module
