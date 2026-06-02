using Base: indexoffset
using LinearAlgebra
using Rotations

include("shapes.jl")


function rotate_lines(linespaces, theta_1, theta_2, theta_3)
    rot_x = RotX(theta_1)
    rot_y = RotY(theta_2)
    rot_z = RotZ(theta_3)

    # Cleaned up rotation order to match your intent
    combined_rot = rot_z * rot_y * rot_x

    for index in eachindex(linespaces)
        linespaces[index] = collect(combined_rot * linespaces[index])
    end
    return linespaces
end

function transform_lines_to_buffer_coords_continuous(linespaces, rows, cols, z_offset)
    for index in eachindex(linespaces)
        linespaces[index] += [0.0, 0.0, z_offset]
    end
    return linespaces
end

function write_lines_into_buffer_discrete(buffer, linespaces)
    fill!(buffer, ' ')
    rows, cols = size(buffer)
    depth_buffer = zeros(Float64, rows, cols)
    
    f = 10.0 
    aspect_ratio = 2.2
    
    # Unified character ramp
    luminance_chars = ".,-~:;=!*#@"
    
    for point in linespaces
        z_depth = point[3]
        if z_depth <= 0 continue end
        
        r_proj = Int(round(point[1] * f / z_depth + rows / 2))
        c_proj = Int(round((point[2] * f / z_depth) * aspect_ratio + cols / 2))
        
        if 1 <= r_proj <= rows && 1 <= c_proj <= cols
            ooz = 1.0 / z_depth
            
            if ooz > depth_buffer[r_proj, c_proj]
                depth_buffer[r_proj, c_proj] = ooz
                
                # Dynamic scaling index based on your z-depth layer (ooz ranges from ~0.028 to ~0.04)
                idx = Int(clamp(round((ooz - 0.025) * 600), 1, length(luminance_chars)))
                
                buffer[r_proj, c_proj] = luminance_chars[idx]
            end
        end
    end

    return buffer
end

function get_color_string(idx, max_idx)
    frequency = (Float64(idx) / Float64(max_idx)) * 2π 
    
    r = Int(clamp(round(sin(frequency) * 127.0 + 128.0), 0, 255))
    g = Int(clamp(round(sin(frequency + 2π/3) * 127.0 + 128.0), 0, 255))
    b = Int(clamp(round(sin(frequency + 4π/3) * 127.0 + 128.0), 0, 255))
    
    return "\e[38;2;$(r);$(g);$(b)m"
end

function print_buffer(buffer)
    # Uses the same matched 11-char string
    luminance_chars = ".,-~:;=!*#@"
    max_idx = length(luminance_chars)
    
    for y in 1:size(buffer, 1)
        for x in 1:size(buffer, 2)
            char = buffer[y, x]
            
            if char == ' '
                print(' ')
            else
                idx = something(findfirst(==(char), luminance_chars), 1)
                color_code = get_color_string(idx, max_idx)
                print(color_code, char, "\e[0m")
            end
        end
        print("\n")
    end
end

function animate(buffer)
    vertices = generate_hyperboloid_vertices()

    print("\e[?1049h") # Alternate screen buffer on
    try
        print("\e[?25l") # Hide cursor
        for i in 1:num_frames
            print("\e[H") 
            println("Animating Torus Frame: $i\n\n")
            
            transformed_coords = deepcopy(vertices)
            transform_lines_to_buffer_coords_continuous(transformed_coords, rows, cols, z_offset)
            buffer = write_lines_into_buffer_discrete(buffer, transformed_coords)

            theta_1 = 1/5 * sin(2 * i * trig_factor)
            theta_2 = 1/7 * sin(i * trig_factor)
            theta_3 = 1/10 # * cos(1/3 * i * trig_factor)
            
            print_buffer(buffer)
        
            vertices = rotate_lines(vertices, theta_1, theta_2, theta_3)
            sleep(0.01)
        end
        
    finally
        print("\e[?25h")  # Show cursor
        print("\e[?1049l") # Alternate screen buffer off
    end
end

rows, cols = 30, 100
z_offset = 30
height, width, depth = 15, 15, 15
num_frames = 300
trig_factor = 1/num_frames * 2 * 3.14159265

buffer = fill(' ', rows, cols)

animate(buffer)
