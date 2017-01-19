local modname = ...   
local M = {}   
_G[modname] = M

function M.create(id, addr)
    local m = {
    
        ID = id,
        ADDR = addr,
        
        RESTART = 0x80,
        EXTCLK = 0x40,
        AL = 0x20,
        SLEEP = 0x10,
        SUBADR1 = 0x02,
        SUBADR2 = 0x03,
        SUBADR3 = 0x04,
        ALLCALL = 0x01,
        
        INVRT = 0x10,
        OCH = 0x08,
        OUTDRV = 0x04,
        OUTNE_1 = 0x1,
        OUTNE_2 = 0x2,
        OUTNE_3 = 0x3,
    
        ON_L = 0xFA,
        ON_H = 0xFB,
        OFF_L = 0xFC,
        OFF_H = 0xFD,
        
        PRE_SCALE = 0xFE,
        
        init = function(this, pSDA, pSDB)
            return i2c.SLOW == i2c.setup(this.ID, pSDA, pSDB, i2c.SLOW)
        end,

        read = function (this, reg)
            i2c.start(this.ID)
            if not i2c.address(this.ID, this.ADDR, i2c.TRANSMITTER) then
                return nil
            end
            i2c.write(this.ID, reg)
            i2c.stop(this.ID)
            i2c.start(this.ID)
            if not i2c.address(this.ID, this.ADDR, i2c.RECEIVER) then
                return nil
            end
            c = i2c.read(this.ID, 1)
            i2c.stop(this.ID)
            return c:byte(1)
        end,

        write = function (this, reg, ...)
            i2c.start(this.ID)
            if not i2c.address(this.ID, this.ADDR, i2c.TRANSMITTER) then
                return nil
            end
            i2c.write(this.ID, reg)
            len = i2c.write(this.ID, ...)
            i2c.stop(this.ID)
            return len
        end,

        getMode1 = function(this)
            return this:read(0x00)
        end,
        setMode1 = function(this, data)
            return this:write(0x00, data)
        end,

        getMode2 = function(this)
            return this:read(0x01)
        end,
        setMode2 = function(this, data)
            return this:write(0x01, data)
        end,

        getChan = function(this, chan)
            return 6 + chan * 4
        end,

        -- MODE 1

        reset = function(this)
            local mode1 = this:getMode1()
            mode1 = bit.set(mode1, 7)
            this:setMode1(mode1)
            mode1 = bit.clear(mode1, 7)
            this:setMode1(mode1)
        end,

        getExt = function(this)
            return bit.isset(this:getMode1(), 6)
        end,
        setExt = function(this, ext)
            local mode1 = this:getMode1()
            if (ext) then
                mode1 = bit.clear(mode1, 6)
            else
                mode1 = bit.set(mode1, 6)
            end
            this:setMode1(mode1)
        end,

        getAi = function(this)
            return bit.isset(this:getMode1(), 5)
        end,
        setAi = function(this, ai)
            local mode1 = this:geMode1()
            if (ai) then
                mode1 = bit.clear(mode1, 5)
            else
                mode1 = bit.set(mode1, 5)
            end
            this:setMode1(mode1)
        end,

        getSleep = function(this)
            return bit.isset(this:getMode1(), 4)
        end,
        setSleep = function(this, sleep)
            local mode1 = this:geMode1()
            if (sleep) then
                mode1 = bit.clear(mode1, 4)
            else
                mode1 = bit.set(mode1, 4)
            end
            this:setMode1(mode1)
        end,

        getAC = function(this)
            return bit.isset(this:getMode1(), 0)
        end,
        setAC = function(this, ac)
            local mode1 = this:geMode1()
            if (ac) then
                mode1 = bit.clear(mode1, 0)
            else
                mode1 = bit.set(mode1, 0)
            end
            this:setMode1(mode1)
        end,

        getMode1Table = function(this)
            return {
                ext = this:getExt(),
                ai = this:getAi(),
                sleep = this:getSleep(),
                ac = this:getAC(),
            }
        end,

        -- MODE 2

        getInvrt = function(this)
            return bit.isset(this:getMode2(), 4)
        end,
        setInvrt = function(this, invrt)
            local mode2 = this:geMode2()
            if (invrt) then
                mode2 = bit.clear(mode1, 4)
            else
                mode2 = bit.set(mode1, 4)
            end
            this:setMode2(mode2)
        end,

        getInvrt = function(this)
            return bit.isset(this:getMode2(), 4)
        end,
        setInvrt = function(this, invrt)
            local mode2 = this:geMode2()
            if (invrt) then
                mode2 = bit.clear(mode2, 4)
            else
                mode2 = bit.set(mode2, 4)
            end
            this:setMode2(mode2)
        end,

        getOch = function(this)
            return bit.isset(this:getMode2(), 3)
        end,
        setOch = function(this, och)
            local mode2 = this:geMode2()
            if (och) then
                mode2 = bit.clear(mode2, 3)
            else
                mode2 = bit.set(mode2, 3)
            end
            this:setMode2(mode2)
        end,
        
        getOutDrv = function(this)
            return bit.isset(this:getMode2(), 2)
        end,
        setOutDrv = function(this, outDrv)
            local mode2 = this:geMode2()
            if (outDrv) then
                mode2 = bit.clear(mode2, 2)
            else
                mode2 = bit.set(mode2, 2)
            end
            this:setMode2(mode2)
        end,

        getOutNe = function(this)
            return bit.band(this:getMode2(), 3)
        end,
        setOutNe = function(this, outne)
            local mode2 = this:geMode2()
            this:setMode2(bit.bor(mode2, bit.band(outne, 3)))
        end,

        getMode2Table = function(this)
            return {
                invrt = this:getInvrt(),
                och = this:getOch(),
                outDrv = this:getOutDrv(),
                outNe = this:getOutNe(),
            }
        end,

        -- CNAHEL

        setOn = function(this, chan, data)
            this:write(this:getChan(chan), bit.band(data, 0xFF))
            this:write(this:getChan(chan) + 1, bit.rshift(data, 8))
        end,
        
        setOff = function(this, chan, data)
            this:write(this:getChan(chan) + 2, bit.band(data, 0xFF))
            this:write(this:getChan(chan) + 3, bit.rshift(data, 8))
        end,

        setOnOf = function(this, chan, dataStart, dataEdn)
            this:setOn(chan, dataStart)
            this:setOff(chan, dataEdn)
        end,

        -- SCALE

        getFq = function(this)
            local fq = this:read(this.PRE_SCALE)
            return math.floor(25000000 / ( fq + 1) / 4096)
        end,
        setFq = function(this, fq)
            local fq = math.floor(25000000 / ( fq * 4096 ) - 1)
            local oldm1 = this:read(0x00);
            this:setMode1(bit.bor(oldm1, this.SLEEP))
            this:write(this.PRE_SCALE, fq)
            this:setMode1(oldm1)
            return nil
        end
    }
    return m
end

return M
