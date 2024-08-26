	; --- Число секунд с полуночи 1 января 2001 года: 0x2c7cf150 ---

assembly
	org 1000h

	; --- Constants ---
	SCREEN_WIDTH equ 32
	SCREEN_HEIGHT equ 24
	SNAKE_COLOR equ 7
	FOOD_COLOR equ 1
	DELAY equ 100

	; --- Variables ---
	snake_x dw 16
	snake_y dw 12
	snake_dir dw 0
	snake_len dw 3
	food_x dw 0
	food_y dw 0

	; --- Routines ---
	
	; --- Delay routine ---
	delay:
		push de
		ld hl, DELAY
		ld de, 0
delay_loop:
		dec hl
		jr nz, delay_loop
		pop de
		ret

	; --- Draw pixel routine ---
	draw_pixel:
		push hl
		push de
		ld hl, (snake_x)
		add hl, de
		ld a, (hl)
		or a
		jr nz, draw_pixel_exit
		ld a, (snake_color)
		ld (hl), a
		draw_pixel_exit:
		pop de
		pop hl
		ret

	; --- Clear pixel routine ---
	clear_pixel:
		push hl
		push de
		ld hl, (snake_x)
		add hl, de
		ld a, 0
		ld (hl), a
		pop de
		pop hl
		ret

	; --- Draw snake routine ---
	draw_snake:
		push de
		push bc
		ld de, 0
		ld hl, (snake_len)
		ld bc, 0
draw_snake_loop:
		dec hl
		jr z, draw_snake_exit
		add hl, de
		call draw_pixel
		inc de
		inc de
		ld bc, 1
		jr draw_snake_loop
draw_snake_exit:
		pop bc
		pop de
		ret

	; --- Clear snake routine ---
	clear_snake:
		push de
		push bc
		ld de, 0
		ld hl, (snake_len)
		ld bc, 0
clear_snake_loop:
		dec hl
		jr z, clear_snake_exit
		add hl, de
		call clear_pixel
		inc de
		inc de
		ld bc, 1
		jr clear_snake_loop
clear_snake_exit:
		pop bc
		pop de
		ret

	; --- Generate food routine ---
	generate_food:
		call random_number
		ld a, l
		and 31
		ld (food_x), a
		call random_number
		ld a, l
		and 23
		ld (food_y), a
		call draw_pixel
		ret

	; --- Random number generator ---
	random_number:
		ld a, (snake_len)
		ld hl, 0
		add hl, sp
		ld (hl), a
		ld a, (snake_x)
		ld hl, 2
		add hl, sp
		ld (hl), a
		ld a, (snake_y)
		ld hl, 4
		add hl, sp
		ld (hl), a
		call rand
		ld hl, 6
		add hl, sp
		ld a, (hl)
		ld l, a
		ld h, 0
		ret

	; --- Random number generation algorithm ---
	rand:
		ld a, (hl)
		add a, 13
		ld (hl), a
		ret

	; --- Move snake routine ---
	move_snake:
		push hl
		ld hl, (snake_x)
		ld a, (hl)
		ld (snake_x + 2), a
		ld hl, (snake_y)
		ld a, (hl)
		ld (snake_y + 2), a
		ld hl, (snake_dir)
		ld a, (hl)
		cp 0
		jr z, move_snake_up
		cp 1
		jr z, move_snake_down
		cp 2
		jr z, move_snake_left
		jr move_snake_right
	move_snake_up:
		dec (snake_y)
		jr move_snake_end
	move_snake_down:
		inc (snake_y)
		jr move_snake_end
	move_snake_left:
		dec (snake_x)
		jr move_snake_end
	move_snake_right:
		inc (snake_x)
	move_snake_end:
		pop hl
		ret

	; --- Check collision routine ---
	check_collision:
		ld hl, (snake_x)
		ld a, (hl)
		cp 0
		jr z, collision
		cp 32
		jr z, collision
		ld hl, (snake_y)
		ld a, (hl)
		cp 0
		jr z, collision
		cp 24
		jr z, collision
		ld hl, (snake_x)
		ld a, (hl)
		ld hl, (snake_len)
		ld c, a
		ld hl, (snake_y)
		ld b, a
		ld de, 2
check_collision_loop:
		dec hl
		jr z, no_collision
		add hl, de
		ld a, (hl)
		cp b
		jr nz, check_collision_loop
		ld a, (hl + 1)
		cp c
		jr nz, check_collision_loop
		jr collision
	no_collision:
		ret
	collision:
		ld hl, (snake_len)
		dec hl
		ld (snake_len), hl
		ret

	; --- Eat food routine ---
	eat_food:
		ld hl, (snake_x)
		ld a, (hl)
		cp (food_x)
		jr nz, eat_food_exit
		ld hl, (snake_y)
		ld a, (hl)
		cp (food_y)
		jr nz, eat_food_exit
		call clear_pixel
		call generate_food
		inc (snake_len)
	eat_food_exit:
		ret

	; --- Main loop ---
	main:
		call draw_snake
		call move_snake
		call check_collision
		call eat_food
		call delay
		call clear_snake
		jr main

	; --- Initialize game ---
	init:
		call generate_food
		call draw_snake
		ret

	; --- Start game ---
	start:
		call init
		jr main
		
		
		
