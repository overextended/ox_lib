--[[
    Adapted from https://github.com/citizenfx/lua/blob/luaglm-548/libs/scripts/examples/dataview.lua

    Copyright © 2026 Linden <https://github.com/thelindat>
    Copyright © 2020 gottfriedleibniz <https://github.com/gottfriedleibniz>

    This file is licensed under The MIT License <https://mit-license.org/>

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---@meta Ox.DataView

---@alias DataViewGet<T> fun(self: DataView, offset?: integer, bigEndian?: boolean): T
---@alias DataViewSet<T> fun(self: DataView, offset: integer, value: T, bigEndian?: boolean): DataView

---@class DataView : OxClass
---@field new DataViewConstructor
---@field getInt8 DataViewGet<integer>
---@field getUint8 DataViewGet<integer>
---@field getInt16 DataViewGet<integer>
---@field getUint16 DataViewGet<integer>
---@field getInt32 DataViewGet<integer>
---@field getUint32 DataViewGet<integer>
---@field getInt64 DataViewGet<integer>
---@field getUint64 DataViewGet<integer>
---@field getFloat32 DataViewGet<number>
---@field getFloat64 DataViewGet<number>
---@field getLuaInt DataViewGet<integer>
---@field getUluaInt DataViewGet<integer>
---@field getLuaNum DataViewGet<number>
---@field getString DataViewGet<string>
---@field setInt8 DataViewSet<integer>
---@field setUint8 DataViewSet<integer>
---@field setInt16 DataViewSet<integer>
---@field setUint16 DataViewSet<integer>
---@field setInt32 DataViewSet<integer>
---@field setUint32 DataViewSet<integer>
---@field setInt64 DataViewSet<integer>
---@field setUint64 DataViewSet<integer>
---@field setFloat32 DataViewSet<number>
---@field setFloat64 DataViewSet<number>
---@field setLuaInt DataViewSet<integer>
---@field setUluaInt DataViewSet<integer>
---@field setLuaNum DataViewSet<number>
---@field setString DataViewSet<string>
local DataView = lib.class('DataView')

---@class DataViewConstructor
---@overload fun(self: DataView, length: integer): DataView
---@private
function DataView:constructor(length)
    length = math.tointeger(length)

    self.blob = string.blob(length)
    self.length = length
    self.offset = 1
    self.cangrow = true
end

local codes = {
    Int8 = 'i1',
    Uint8 = 'I1',
    Int16 = 'i2',
    Uint16 = 'I2',
    Int32 = 'i4',
    Uint32 = 'I4',
    Int64 = 'i8',
    Uint64 = 'I8',
    Float32 = 'f',
    Float64 = 'd',
    LuaInt = 'j',
    UluaInt = 'J',
    LuaNum = 'n',
    String = 'z'
}

local sizes = {
    String = -1,
}

local function format(big, code)
    return (big and '>' or '<') .. code
end

local function packblob(self, offset, value, code)
    local packed = self.blob:blob_pack(offset, code, value)

    if self.cangrow or packed == self.blob then
        self.blob = packed
        self.length = packed:len()
        return true
    else
        return false
    end
end

for type, code in pairs(codes) do
    local size = sizes[type] or string.packsize(code)
    sizes[type] = size

    DataView['get' .. type] = function(self, offset, bigEndian)
        offset = offset or 0

        if offset >= 0 then
            local value = self.blob:blob_unpack(self.offset + offset, format(bigEndian, code))

            return value
        end
    end

    DataView['set' .. type] = function(self, offset, value, bigEndian)
        if offset >= 0 and value then
            local o = self.offset + offset
            local length = (size < 0 and value:len()) or size

            if self.cangrow or ((o + (length - 1)) <= self.length) then
                if not packblob(self, o, value, format(bigEndian, code)) then
                    error('cannot grow subview')
                end
            else
                error('cannot grow dataview')
            end
        end

        return self
    end
end

return DataView
