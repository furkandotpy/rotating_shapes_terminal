function generate_hyperboloid_vertices()
    points = Vector{Float64}[]
    
    # Structural parameters
    a, b = 7.0, 7.0   # Waist radius (skinniness of the center center)
    c = 10.0          # Vertical scaling factor
    
    u_step = 0.4      # Vertical steps
    v_step = 0.08     # Angular steps around the ring
    
    # u controls the height profile (from bottom to top)
    for u in -1.5:u_step:1.5
        # v sweeps around the circular cross-section
        for v in 0:v_step:2π
            
            # Parametric equations for a hyperboloid of one sheet
            x = a * cos(v) * cosh(u)
            y = b * sin(v) * cosh(u)
            z = c * sinh(u)
            
            push!(points, [x, y, z])
        end
    end
    
    return points
end


function generate_cube_vertices()
    linespace_1 =  [[ i, -width,  depth] for i in range(-height, height)] 
    linespace_2 =  [[ i, -width, -depth] for i in range(-height, height)]
    linespace_3 =  [[ i,  width,  depth] for i in range(-height, height)]
    linespace_4 =  [[ i,  width, -depth] for i in range(-height, height)]
    
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
    
    R = 12.0  # Major radius
    r = 5.0   # Minor radius
    
    theta_step = 0.15
    phi_step = 0.05
    
    for phi in 0:phi_step:2π
        for theta in 0:theta_step:2π
            x = (R + r * cos(theta)) * cos(phi)
            y = (R + r * cos(theta)) * sin(phi)
            z = r * sin(theta)
            
            push!(points, [x, y, z])
        end
    end
    
    return points
end
