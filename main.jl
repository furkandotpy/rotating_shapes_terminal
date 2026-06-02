using Base: indexoffset
using LinearAlgebra
using Rotations


function generate_cube_vertices()

    linespace_1 =  [[  i, -width,  depth] for i in range(-height, height)] 
    linespace_2 =  [[  i, -width, -depth] for i in range(-height, height)]
    linespace_3 =  [[  i,  width,  depth] for i in range(-height, height)]
    linespace_4 =  [[  i,  width, -depth] for i in range(-height, height)]
    
    linespace_5 =  [[-height,  i, -depth] for i in range(-width, width)]
    linespace_6 =  [[-height,  i,  depth] for i in range(-width, width)]
    linespace_7 =  [[ height,  i, -depth] for i in range(-width, width)]
    linespace_8 =  [[ height,  i,  depth] for i in range(-width, width)]

    linespace_9 =  [[-height, -width,  i] for i in range(-depth, depth)]
    linespace_10 = [[-height,  width,  i] for i in range(-depth, depth)]
    linespace_11 = [[ height, -width,  i] for i in range(-depth, depth)]
    linespace_12 = [[ height,  width,  i] for i in range(-depth, depth)]

    linespaces = Vector{Float64}.(vcat(
        linespace_1,  linespace_2,  linespace_3,
        linespace_4,  linespace_5,  linespace_6,
        linespace_7,  linespace_8,  linespace_9,
        linespace_10, linespace_11, linespace_12
    ))
    return linespaces    
end


function rotate_lines(linespaces, theta_1, theta_2, theta_3)
    rot_x = RotX(theta_1)
    rot_y = RotY(theta_2)
    rot_z = RotZ(theta_3)

    for index in eachindex(linespaces)
        linespaces[index] = rot_x * linespaces[index]
        linespaces[index] = rot_y * linespaces[index]
        linespaces[index] = rot_z * linespaces[index]
    end
    return linespaces
end


function transform_lines_to_buffer_coords_continuous(linespaces, rows, cols, z_offset)
    for index in eachindex(linespaces)
        linespaces[index] += [rows//2 - 1, cols//2 - 1, z_offset]
    end
    return linespaces
end


function write_lines_into_buffer_discrete(buffer, linespaces)
    fill!(buffer, ' ')
    rows, cols = size(buffer)
    
    # Perspective projection constant (how "deep" the field of view is)
    f = 10.0 

    for point in linespaces
        # 1. Perspective Projection: x' = x * f / z
        # We add a small constant to z to avoid division by zero
        z_depth = point[3] + 1e-10
        
        # 2. Project and scale
        # We map -5 to 5 space into a visible screen space
        r_proj = Int(round(point[1] * f / z_depth))
        c_proj = Int(round(point[2] * f / z_depth))
        
        # 3. Bounds check
        if 1 <= r_proj <= rows && 1 <= c_proj <= cols
            buffer[r_proj, c_proj] = '#'
        end
    end

    return buffer
end


function print_buffer(buffer)
    for y in 1:size(buffer, 1)
        for x in 1:size(buffer, 2)
            print(buffer[y, x])
        end
        print("\n")
    end
    
end


function animate(buffer)
    vertices = generate_cube_vertices()

    print("\e[?1049h")
    try
        print("\e[?25l")
        for i in 1:100
            print("\e[H") 
            println("Animating Cube Frame: $i\n\n")
            linespaces_buffer_coords = transform_lines_to_buffer_coords_continuous(vertices, rows, cols, z_offset)
            buffer = write_lines_into_buffer_discrete(buffer, linespaces_buffer_coords)
            print_buffer(buffer)
            vertices = rotate_lines(vertices, 1, 1, 1)
            sleep(1.0)
        end
        
    finally
        print("\e[?25h")
        print("\e[?1049l")
    end
end

rows, cols = 30, 30
z_offset = 30
height, width, depth = 5, 5, 5

buffer = fill(' ', rows, cols)

animate(buffer)
