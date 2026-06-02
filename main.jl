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

function generate_torus_vertices()
    points = Vector{Float64}[]
    
    # Configuration for the torus geometry
    R = 12.0  # Major radius (distance from center to core of tube)
    r = 5.0   # Minor radius (radius of the tube)
    
    # Sampling density (higher means more points/denser render)
    theta_step = 0.15
    phi_step = 0.05
    
    # 1. Sweep phi around the main circle (0 to 2π)
    for phi in 0:phi_step:2π
        # 2. Sweep theta around the cross-section tube (0 to 2π)
        for theta in 0:theta_step:2π
            
            # Parametric equations for a torus
            x = (R + r * cos(theta)) * cos(phi)
            y = (R + r * cos(theta)) * sin(phi)
            z = r * sin(theta)
            
            push!(points, [x, y, z])
        end
    end
    
    return points
end

function rotate_lines(linespaces, theta_1, theta_2, theta_3)
    rot_x = RotX(theta_1)
    rot_y = RotY(theta_2)
    rot_z = RotZ(theta_3)

    for index in eachindex(linespaces)
        linespaces[index] = collect(rot_x * rot_y * rot_y * linespaces[index])
    end
    return linespaces
end


function transform_lines_to_buffer_coords_continuous(linespaces, rows, cols, z_offset)
    for index in eachindex(linespaces)
        linespaces[index] += [0, 0, z_offset]
    end
    return linespaces
end


function write_lines_into_buffer_discrete(buffer, linespaces)
    fill!(buffer, ' ')
    rows, cols = size(buffer)
    
    # Perspective projection constant (how "deep" the field of view is)
    f = 10.0 
    aspect_ratio = 2
    
    for point in linespaces
        # 1. Perspective Projection: x' = x * f / z
        # We add a small constant to z to avoid division by zero
        z_depth = point[3] + 1e-10
        
        # 2. Project and scale
        # We map -5 to 5 space into a visible screen space
        r_proj = Int(round(point[1] * f / z_depth + rows/2))
        c_proj = Int(round(point[2] * f / z_depth * aspect_ratio + cols/2))
        
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
    vertices = generate_torus_vertices()

    print("\e[?1049h")
    try
        print("\e[?25l")
        for i in 1:1000
            print("\e[H") 
            println("Animating Cube Frame: $i\n\n")
            transformed_coords = deepcopy(vertices)
            transform_lines_to_buffer_coords_continuous(transformed_coords, rows, cols, z_offset)
            buffer = write_lines_into_buffer_discrete(buffer, transformed_coords)
            print_buffer(buffer)
            vertices = rotate_lines(vertices, 0.1, 0.0, 0.0)
            sleep(0.01)
        end
        
    finally
        print("\e[?25h")
        print("\e[?1049l")
    end
end

rows, cols = 30, 100
z_offset = 30
height, width, depth = 15, 15, 15

buffer = fill(' ', rows, cols)

animate(buffer)
