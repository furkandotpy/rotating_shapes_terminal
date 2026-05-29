using LinearAlgebra
using Rotations

rows, cols = 30, 130
z_offset = 30
height, width, depth = 20, 20, 20

buffer = fill(' ', rows, cols)

function generate_cube_vertices()

    linspace_1 =  [[  i, -width,  depth] for i in range(-height, height)] 
    linspace_2 =  [[  i, -width, -depth] for i in range(-height, height)]
    linspace_3 =  [[  i,  width,  depth] for i in range(-height, height)]
    linspace_4 =  [[  i,  width, -depth] for i in range(-height, height)]
    
    linspace_5 =  [[-height,  i, -depth] for i in range(-width, width)]
    linspace_6 =  [[-height,  i,  depth] for i in range(-width, width)]
    linspace_7 =  [[ height,  i, -depth] for i in range(-width, width)]
    linspace_8 =  [[ height,  i,  depth] for i in range(-width, width)]

    linspace_9 =  [[-height, -width,  i] for i in range(-depth, depth)]
    linspace_10 = [[-height,  width,  i] for i in range(-depth, depth)]
    linspace_11 = [[ height, -width,  i] for i in range(-depth, depth)]
    linspace_12 = [[ height,  width,  i] for i in range(-depth, depth)]

    linspaces = [
                    linspace_1,  linspace_2,  linspace_3,
                    linspace_4,  linspace_5,  linspace_6,
                    linspace_7,  linspace_8,  linspace_9,
                    linspace_10, linspace_11, linspace_12
                ]
                
    return linspaces
    
end


function transform_lines_to_buffer_coords(lines, rows, cols, z_offset)
    for linspace in 1:size(linspaces, 1)
        for point in 1:size(linspaces[linspace], 1)
            linspaces[linspace][point] += [rows//2 - 1, cols//2 - 1, z_offset]
        end
    end
    return linspaces
end


function rotate_lines!(buffer, theta_1, theta_2, theta_3)
    rot_x = RotX(theta_1)
    rot_y = RotY(theta_2)
    rot_z = RotZ(theta_3)
    
    for y in 1:size(buffer, 1)
        for x in 1:size(buffer, 2)
            buffer[x, y] *= rot_x
            buffer[x, y] *= rot_y
            buffer[x, y] *= rot_z
        end
    end
    
end


function write_lines_into_buffer!(buffer, lines)
    fill!(buffer, ' ')
    rows, cols = size(buffer)
    
    # Perspective projection constant (how "deep" the field of view is)
    f = 10.0 

    for linspace in lines
        for point in linspace
            # 1. Perspective Projection: x' = x * f / z
            # We add a small constant to z to avoid division by zero
            z_depth = point[3]
            
            # 2. Project and scale
            # We map -5 to 5 space into a visible screen space
            r_proj = Int(round(point[1] * f / z_depth + rows/2))
            c_proj = Int(round(point[2] * f / z_depth + cols/2))
            
            # 3. Bounds check
            if 1 <= r_proj <= rows && 1 <= c_proj <= cols
                buffer[r_proj, c_proj] = '#'
            end
        end
    end
end


function print_buffer(bufffer)
    for y in 1:size(buffer, 1)
        for x in 1:size(buffer, 2)
            print(buffer[y, x])
        end
        print("\n")
    end
    
end


function animate(buffer)

    print("\e[?1049h")
    try
        print("\e[?25l")
    
        for i in 1:100
            print("\e[H") 
            println("Animating Cube Frame: $i\n\n")
            print_buffer(buffer)
            write_lines_into_buffer!(buffer)
            rotate_lines!(buffer)
            sleep(0.3)
        end
        
    finally
        print("\e[?25h")
        print("\e[?1049l")
    end
end


println(1)
linspaces = generate_cube_vertices()
println(2)
linspaces_buffer_coords = transform_lines_to_buffer_coords(linspaces, rows, cols, z_offset)
println(3)
write_lines_into_buffer!(buffer, linspaces_buffer_coords)
println(4)
animate(buffer)
println(5)
