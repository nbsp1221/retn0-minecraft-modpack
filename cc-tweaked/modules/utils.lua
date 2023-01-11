--- @param condition boolean
--- @param trueValue unknown
--- @param falseValue unknown
local function fif(condition, trueValue, falseValue)
    if condition then
        return trueValue
    else
        return falseValue
    end
end

return {
    fif = fif,
}
