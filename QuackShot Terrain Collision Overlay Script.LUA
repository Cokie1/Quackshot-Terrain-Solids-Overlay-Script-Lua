rw = memory.readword
rl = memory.readlong
rb = memory.readbyte
block_size = 16

COLOR = 0xFFFF007f

function ASR_WORD(val,amt)

	-- ASSURE is word
	local val_word = AND(val,0xFFFF)
	local EXTEND_MASK = 0x8000
	local MSB_SIGN = SHIFT( AND(val_word,EXTEND_MASK) ,15)
	 
	
	if MSB_SIGN == 1 then
		local EXTEND_MASK_CHANGING = EXTEND_MASK
		for i = 1,amt do	
			EXTEND_MASK_CHANGING = EXTEND_MASK_CHANGING + SHIFT(EXTEND_MASK,i)
		end	

		return OR(SHIFT(val_word,amt),EXTEND_MASK_CHANGING) 	
	else
		return SHIFT(val_word,amt) 
	end
end

BLOCK_COARSE_MASK = 0xFFF0
gui.register(function()

	local camx = rw(0xff852C)
	local camy = rw(0xff8520)
 
	local  camx_course = AND(BLOCK_COARSE_MASK,camx)
	local  camy_course = AND(BLOCK_COARSE_MASK,camy)

	local camxscreen_course = camx_course - camx 
	local camyscreen_course = camy_course - camy

	for block_x_number = 0 , 20 do
	
		local block_x = block_x_number * 16
		local x_temp = camxscreen_course + block_x 

		for block_y_number = 0 , 14 do
	
			local block_y = block_y_number * 16
			local y_temp = camyscreen_course + block_y 				
			
			local d4 = camx + block_x  
			local d5 = camy + block_y 
 
			local a2 = rl(0xFF8510)
			d4 = ASR_WORD(d4,8)
			d5 = ASR_WORD(d5,8)
			d5 = SHIFT(d5,-5)
			d4 = d5 + d4
			d4 = rb(a2+d4)
			a2 = rl(0xFF8514)
			d4 = SHIFT(d4,-8)
			d5 = camx + block_x 
			d5 = SHIFT(d5,4)
			d5 = AND(d5,0xf)
			d5 = d5 + d4
			d4 = camy + block_y 
			d4 = AND(d4,0xf0)
			d5 = d5 + d4
			d4 = 0
			d4 = rb(a2+d5)

			----------
			d7 = 0
			a2 = 0xff8A00
			d7 = rb(a2 + d4)

			----------


			if d7 ~= 0 then
				gui.rect(x_temp,y_temp,x_temp+15,y_temp+15,COLOR ,COLOR )
				gui.text(x_temp+6,y_temp+6,d7,"white","black")
			else
				-- Debug Test
				--gui.rect(x_temp,y_temp,x_temp+15,y_temp+15,0XAAAAAA90,0XAAAAAA90)
				--gui.text(x_temp+6,y_temp+6,d7,"white","black")
			end
		end
	end
end)