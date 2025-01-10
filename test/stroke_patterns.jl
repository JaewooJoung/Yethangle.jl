# src/stroke_patterns.jl

"""
Get stroke patterns for initial consonants
"""
function get_initial_strokes(char::Char)::Vector{Vector{Tuple{Int, Int}}}
    strokes = Dict{Char, Vector{Vector{Tuple{Int, Int}}}}(
        'ᄀ' => [[(1,6), (6,6)], [(6,6), (6,2)]],
        'ᄁ' => [[(1,6), (6,6)], [(6,6), (6,2)], [(2,5), (5,5)], [(5,5), (5,3)]],
        'ᄂ' => [[(1,2), (1,6)], [(1,6), (6,6)]],
        'ᄃ' => [[(1,6), (6,6)], [(3,4), (6,4)], [(6,6), (6,2)]],
        'ᄄ' => [[(1,6), (6,6)], [(3,4), (6,4)], [(6,6), (6,2)], [(2,5), (5,5)]],
        'ᄅ' => [[(1,6), (6,6)], [(3,4), (4,4)], [(6,6), (6,2)]],
        'ᄆ' => [[(1,2), (1,6)], [(1,6), (6,6)], [(6,6), (6,2)], [(1,4), (6,4)]],
        'ᄇ' => [[(1,2), (1,6)], [(1,6), (6,6)], [(6,6), (6,2)], [(1,4), (6,4)]],
        'ᄈ' => [[(1,2), (1,6)], [(1,6), (6,6)], [(6,6), (6,2)], [(1,4), (6,4)], [(2,5), (5,5)]],
        'ᄉ' => [[(2,6), (4,4)], [(4,4), (6,6)]],
        'ᄊ' => [[(2,6), (4,4)], [(4,4), (6,6)], [(1,5), (3,3)], [(3,3), (5,5)]],
        'ᄋ' => [[(3,2), (3,6)], [(1,4), (5,4)]],
        'ᄌ' => [[(1,6), (6,6)], [(3,4), (4,4)], [(6,6), (6,2)]],
        'ᄍ' => [[(1,6), (6,6)], [(3,4), (4,4)], [(6,6), (6,2)], [(2,5), (5,5)]],
        'ᄎ' => [[(1,6), (6,6)], [(3,4), (4,4)], [(6,6), (6,2)], [(2,5), (5,5)]],
        'ᄏ' => [[(1,6), (6,6)], [(6,6), (6,2)], [(3,4), (5,4)]],
        'ᄐ' => [[(1,6), (6,6)], [(3,4), (6,4)], [(6,6), (6,2)]],
        'ᄑ' => [[(1,6), (6,6)], [(3,4), (6,4)], [(6,6), (6,2)], [(2,5), (5,5)]],
        'ᄒ' => [[(2,6), (4,4)], [(4,4), (6,2)]],
        'ㆁ' => [[(2,3), (5,3)], [(2,3), (2,5)], [(5,3), (5,5)], [(2,5), (5,5)]],
        'ㆆ' => [[(2,3), (5,3)], [(2,5), (5,5)]],
        'ㅿ' => [[(2,3), (4,5)], [(4,5), (5,3)]]
    )
    
    return get(strokes, char, [[(1,1), (6,6)]])  # Default stroke if char not found
end

"""
Get stroke patterns for vowels
"""
function get_vowel_strokes(char::Char)::Vector{Vector{Tuple{Int, Int}}}
    strokes = Dict{Char, Vector{Vector{Tuple{Int, Int}}}}(
        'ㅏ' => [[(4,1), (4,6)], [(4,3), (6,3)]],
        'ㅐ' => [[(3,1), (3,6)], [(3,3), (5,3)], [(6,1), (6,6)]],
        'ㅑ' => [[(3,1), (3,6)], [(3,3), (6,3)], [(4,2), (4,5)]],
        'ㅒ' => [[(2,1), (2,6)], [(2,3), (5,3)], [(3,2), (3,5)], [(6,1), (6,6)]],
        'ㅓ' => [[(3,1), (3,6)], [(1,3), (3,3)]],
        'ㅔ' => [[(3,1), (3,6)], [(1,3), (3,3)], [(5,1), (5,6)]],
        'ㅕ' => [[(4,1), (4,6)], [(1,3), (4,3)], [(2,2), (2,5)]],
        'ㅖ' => [[(3,1), (3,6)], [(1,3), (3,3)], [(4,2), (4,5)], [(6,1), (6,6)]],
        'ㅗ' => [[(1,4), (6,4)], [(3,4), (3,6)]],
        'ㅘ' => [[(1,4), (6,4)], [(3,4), (3,6)], [(5,1), (5,6)]],
        'ㅙ' => [[(1,4), (6,4)], [(3,4), (3,6)], [(5,1), (5,6)], [(6,1), (6,6)]],
        'ㅚ' => [[(1,4), (6,4)], [(3,4), (3,6)], [(5,1), (5,6)]],
        'ㅛ' => [[(1,4), (6,4)], [(2,3), (2,5)], [(5,3), (5,5)]],
        'ㅜ' => [[(1,3), (6,3)], [(3,1), (3,3)]],
        'ㅝ' => [[(1,3), (6,3)], [(3,1), (3,3)], [(5,1), (5,6)]],
        'ㅞ' => [[(1,3), (6,3)], [(3,1), (3,3)], [(5,1), (5,6)], [(6,1), (6,6)]],
        'ㅟ' => [[(1,3), (6,3)], [(3,1), (3,3)], [(5,1), (5,6)]],
        'ㅠ' => [[(1,3), (6,3)], [(2,1), (2,3)], [(5,1), (5,3)]],
        'ㅡ' => [[(1,4), (6,4)]],
        'ㅢ' => [[(1,4), (6,4)], [(3,1), (3,6)]],
        'ㅣ' => [[(3,1), (3,6)]],
        'ㆍ' => [[(3,3), (4,3)], [(3,4), (4,4)]],  # Small square for ㆍ
        'ᆢ' => [[(2,2), (3,2)], [(2,3), (3,3)], [(4,4), (5,4)], [(4,5), (5,5)]]  # Two small squares for ᆢ
    )
    
    return get(strokes, char, [[(1,1), (6,6)]])  # Default stroke if char not found
end

"""
Get stroke patterns for final consonants
"""
function get_final_strokes(char::Char)::Vector{Vector{Tuple{Int, Int}}}
    strokes = Dict{Char, Vector{Vector{Tuple{Int, Int}}}}(
        'ᆨ' => [[(1,3), (6,3)], [(6,3), (6,1)]],
        'ᆩ' => [[(1,3), (6,3)], [(6,3), (6,1)], [(2,2), (5,2)], [(5,2), (5,1)]],
        'ᆪ' => [[(1,3), (6,3)], [(6,3), (6,1)], [(3,2), (4,2)]],
        'ᆫ' => [[(1,1), (1,3)], [(1,3), (6,3)]],
        'ᆬ' => [[(1,1), (1,3)], [(1,3), (6,3)], [(3,2), (4,2)]],
        'ᆭ' => [[(1,1), (1,3)], [(1,3), (6,3)], [(4,2), (5,1)]],
        'ᆮ' => [[(1,3), (6,3)], [(3,2), (6,2)], [(6,3), (6,1)]],
        'ᆯ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(6,3), (6,1)]],
        'ᆰ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(6,3), (6,1)], [(5,2), (5,1)]],
        'ᆱ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(5,3), (5,1)]],
        'ᆲ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(6,3), (6,1)], [(2,2), (2,1)]],
        'ᆳ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(2,2), (5,2)]],
        'ᆴ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(5,3), (5,1)], [(2,2), (2,1)]],
        'ᆵ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(2,2), (2,1)], [(5,2), (5,1)]],
        'ᆶ' => [[(1,3), (6,3)], [(2,2), (5,2)], [(3,1), (4,1)]],
        'ᆷ' => [[(1,1), (1,3)], [(1,3), (6,3)], [(6,3), (6,1)], [(1,2), (6,2)]],
        'ᆸ' => [[(1,1), (1,3)], [(1,3), (6,3)], [(6,3), (6,1)], [(1,2), (6,2)]],
        'ᆹ' => [[(1,1), (1,3)], [(1,3), (6,3)], [(6,3), (6,1)], [(1,2), (6,2)], [(3,2), (4,1)]],
        'ᆺ' => [[(2,3), (4,1)], [(4,1), (6,3)]],
        'ᆻ' => [[(2,3), (4,1)], [(4,1), (6,3)], [(1,2), (3,1)], [(3,1), (5,2)]],
        'ᆼ' => [[(2,1), (5,1)], [(2,1), (2,3)], [(5,1), (5,3)], [(2,3), (5,3)]],
        'ᆽ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(6,3), (6,1)]],
        'ᆾ' => [[(1,3), (6,3)], [(3,2), (4,2)], [(6,3), (6,1)], [(2,2), (5,2)]],
        'ᆿ' => [[(1,3), (6,1)], [(1,1), (6,3)]],
        'ᇀ' => [[(2,3), (5,1)], [(2,1), (5,3)]],
        'ᇁ' => [[(1,3), (6,3)], [(3,2), (4,1)]],
        'ᇂ' => [[(3,3), (4,1)], [(2,2), (5,2)]]
    )
    
    return get(strokes, char, [[(1,1), (6,3)]])  # Default stroke if char not found
end

"""
Create a .notdef glyph for missing characters
"""
function create_notdef_glyph()::Glyph
    em_size = Int16(FontConstants.DEFAULT_EM_SQUARE)
    metrics = GlyphMetrics(
        em_size,     # width
        em_size,     # height
        Int16(0),    # horiBearingX
        Int16(floor(em_size * GlyphConstants.BEARING_Y_RATIO)),  # horiBearingY
        UInt16(GlyphConstants.DEFAULT_ADVANCE), # horiAdvance
        Int16(0),    # vertBearingX
        Int16(0),    # vertBearingY
        UInt16(GlyphConstants.DEFAULT_ADVANCE)  # vertAdvance
    )
    
    margin = Int16(100)
    
    # Create a box with a diagonal cross
    outer_points = [
        (margin, margin, true),
        (em_size - margin, margin, true),
        (em_size - margin, em_size - margin, true),
        (margin, em_size - margin, true),
        (margin, margin, true)
    ]
    
    diagonal1 = [
        (margin, margin, true),
        (em_size - margin, em_size - margin, true)
    ]
    
    diagonal2 = [
        (margin, em_size - margin, true),
        (em_size - margin, margin, true)
    ]
    
    outline = GlyphOutline(
        [outer_points, diagonal1, diagonal2],
        margin,
        em_size - margin,
        em_size - margin
    )
    
    return Glyph(metrics, outline)
end

"""
Helper function to convert grid coordinates to actual coordinates
"""
function grid_to_actual_coords(
    points::Vector{Tuple{Int, Int}},
    x::Int16,
    y::Int16,
    width::Int16,
    height::Int16
)::Vector{Tuple{Int16, Int16, Bool}}
    grid_size = GlyphConstants.GRID_DIVISIONS
    cell_width = width ÷ grid_size
    cell_height = height ÷ grid_size
    
    return map(point -> (
        Int16(x + point[1] * cell_width),
        Int16(y + point[2] * cell_height),
        true), points)
end

"""
Helper function to validate stroke coordinates
"""
function validate_stroke_coords(points::Vector{Tuple{Int, Int}})
    if isempty(points)
        throw(ArgumentError("Stroke cannot be empty"))
    end
    
    grid_size = GlyphConstants.GRID_DIVISIONS
    for (i, (x, y)) in enumerate(points)
        if x < 0 || x > grid_size || y < 0 || y > grid_size
            throw(ArgumentError("Point $i ($x,$y) is outside the grid range 0-$grid_size"))
        end
    end
end

"""
Helper function to create diagonal lines
"""
function create_diagonal_line(
    x1::Int,
    y1::Int,
    x2::Int,
    y2::Int,
    steps::Int=5
)::Vector{Tuple{Int, Int}}
    dx = (x2 - x1) / (steps - 1)
    dy = (y2 - y1) / (steps - 1)
    
    return [(Int(round(x1 + dx * i)), Int(round(y1 + dy * i))) for i in 0:(steps-1)]
end

"""
Helper function to create curve approximation
"""
function create_curve(
    x1::Int,
    y1::Int,
    x2::Int,
    y2::Int,
    control_x::Int,
    control_y::Int,
    steps::Int=8
)::Vector{Tuple{Int, Int}}
    points = Vector{Tuple{Int, Int}}()
    
    for t in range(0, 1, length=steps)
        # Quadratic Bezier curve
        x = (1-t)^2 * x1 + 2*(1-t)*t * control_x + t^2 * x2
        y = (1-t)^2 * y1 + 2*(1-t)*t * control_y + t^2 * y2
        push!(points, (Int(round(x)), Int(round(y))))
    end
    
    return points
end

"""
Helper function to create arc segment
"""
function create_arc(
    center_x::Int,
    center_y::Int,
    radius::Int,
    start_angle::Float64,
    end_angle::Float64,
    steps::Int=8
)::Vector{Tuple{Int, Int}}
    points = Vector{Tuple{Int, Int}}()
    
    for t in range(start_angle, end_angle, length=steps)
        x = center_x + Int(round(radius * cos(t)))
        y = center_y + Int(round(radius * sin(t)))
        push!(points, (x, y))
    end
    
    return points
end

"""
Helper function to mirror points horizontally
"""
function mirror_horizontal(
    points::Vector{Tuple{Int, Int}},
    grid_size::Int=GlyphConstants.GRID_DIVISIONS
)::Vector{Tuple{Int, Int}}
    return [(grid_size - x, y) for (x, y) in points]
end

"""
Helper function to mirror points vertically
"""
function mirror_vertical(
    points::Vector{Tuple{Int, Int}},
    grid_size::Int=GlyphConstants.GRID_DIVISIONS
)::Vector{Tuple{Int, Int}}
    return [(x, grid_size - y) for (x, y) in points]
end

"""
Helper function to scale stroke coordinates
"""
function scale_stroke(
    points::Vector{Tuple{Int, Int}},
    scale_x::Float64,
    scale_y::Float64,
    origin_x::Int=0,
    origin_y::Int=0
)::Vector{Tuple{Int, Int}}
    return [
        (
            Int(round(origin_x + (x - origin_x) * scale_x)),
            Int(round(origin_y + (y - origin_y) * scale_y))
        )
        for (x, y) in points
    ]
end

"""
Helper function to rotate stroke coordinates
"""
function rotate_stroke(
    points::Vector{Tuple{Int, Int}},
    angle::Float64,
    origin_x::Int=4,
    origin_y::Int=4
)::Vector{Tuple{Int, Int}}
    cos_a = cos(angle)
    sin_a = sin(angle)
    
    return [
        (
            Int(round(origin_x + (x - origin_x) * cos_a - (y - origin_y) * sin_a)),
            Int(round(origin_y + (x - origin_x) * sin_a + (y - origin_y) * cos_a))
        )
        for (x, y) in points
    ]
end

"""
Helper function to combine multiple strokes
"""
function combine_strokes(strokes::Vector{Vector{Tuple{Int, Int}}})::Vector{Vector{Tuple{Int, Int}}}
    result = Vector{Vector{Tuple{Int, Int}}}()
    for stroke in strokes
        validate_stroke_coords(stroke)
        push!(result, stroke)
    end
    return result
end

# Export helper functions for advanced glyph creation
export grid_to_actual_coords, validate_stroke_coords
export create_diagonal_line, create_curve, create_arc
export mirror_horizontal, mirror_vertical
export scale_stroke, rotate_stroke, combine_strokes