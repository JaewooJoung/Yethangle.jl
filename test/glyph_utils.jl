# src/glyph_utils.jl

"""
Constants for glyph positioning and dimensions
"""
module GlyphConstants
    # Standard Korean typography measurements
    const INITIAL_HEIGHT_RATIO = 0.35    # Initial consonant height ratio
    const VOWEL_HEIGHT_RATIO = 0.35      # Vowel height ratio
    const FINAL_HEIGHT_RATIO = 0.30      # Final consonant height ratio
    
    # Positioning constants
    const MARGIN_RATIO = 0.05            # Margin ratio
    const STROKE_WIDTH_RATIO = 0.08      # Stroke width ratio
    
    # Grid divisions for positioning strokes
    const GRID_DIVISIONS = 8             # Number of grid divisions
    
    # Metrics constants
    const BEARING_Y_RATIO = 0.8          # Default vertical bearing ratio
    const DEFAULT_ADVANCE = 1000         # Default advance width/height
end

"""
Create a stroke contour from a set of points with proper width
"""
function create_stroke_contour(
    points::Vector{Tuple{Int16, Int16, Bool}},
    stroke_width::Int16
)::Vector{Tuple{Int16, Int16, Bool}}
    # Validate input
    if length(points) < 2
        throw(ArgumentError("Stroke must have at least 2 points"))
    end
    
    contour = Vector{Tuple{Int16, Int16, Bool}}()
    half_width = stroke_width ÷ 2
    
    # Create outlines for the stroke
    for i in 1:length(points)-1
        x1, y1 = points[i][1], points[i][2]
        x2, y2 = points[i+1][1], points[i+1][2]
        
        # Calculate vector and length
        dx = Float64(x2 - x1)
        dy = Float64(y2 - y1)
        length = sqrt(dx^2 + dy^2)
        
        if length > 0
            # Calculate normalized perpendicular vector
            nx = Int16(round((-dy / length) * half_width))
            ny = Int16(round((dx / length) * half_width))
            
            # Add points for one side of the stroke
            push!(contour, (x1 + nx, y1 + ny, true))
            push!(contour, (x2 + nx, y2 + ny, true))
        end
    end
    
    # Add return points to complete the contour
    for i in length(points)-1:-1:1
        x1, y1 = points[i][1], points[i][2]
        x2, y2 = points[i+1][1], points[i+1][2]
        
        dx = Float64(x2 - x1)
        dy = Float64(y2 - y1)
        length = sqrt(dx^2 + dy^2)
        
        if length > 0
            nx = Int16(round((-dy / length) * half_width))
            ny = Int16(round((dx / length) * half_width))
            
            push!(contour, (x2 - nx, y2 - ny, true))
            push!(contour, (x1 - nx, y1 - ny, true))
        end
    end
    
    # Close the contour
    if !isempty(contour)
        push!(contour, contour[1])
    end
    
    return contour
end

"""
Create outlines for initial consonant component
"""
function create_initial_component(
    char::Char,
    x::Int16,
    y::Int16,
    width::Int16,
    height::Int16,
    stroke_width::Int16
)::Vector{Vector{Tuple{Int16, Int16, Bool}}}
    # Setup grid
    grid_size = GlyphConstants.GRID_DIVISIONS
    cell_width = width ÷ grid_size
    cell_height = height ÷ grid_size
    
    # Get stroke patterns
    strokes = get_initial_strokes(char)
    
    # Convert grid coordinates to actual coordinates
    contours = Vector{Vector{Tuple{Int16, Int16, Bool}}}()
    for stroke in strokes
        points = map(point -> (
            Int16(x + point[1] * cell_width),
            Int16(y + point[2] * cell_height),
            true
        ), stroke)
        push!(contours, create_stroke_contour(points, stroke_width))
    end
    
    return contours
end

"""
Create outlines for vowel component
"""
function create_vowel_component(
    char::Char,
    x::Int16,
    y::Int16,
    width::Int16,
    height::Int16,
    stroke_width::Int16
)::Vector{Vector{Tuple{Int16, Int16, Bool}}}
    grid_size = GlyphConstants.GRID_DIVISIONS
    cell_width = width ÷ grid_size
    cell_height = height ÷ grid_size
    
    strokes = get_vowel_strokes(char)
    
    contours = Vector{Vector{Tuple{Int16, Int16, Bool}}}()
    for stroke in strokes
        points = map(point -> (
            Int16(x + point[1] * cell_width),
            Int16(y + point[2] * cell_height),
            true
        ), stroke)
        push!(contours, create_stroke_contour(points, stroke_width))
    end
    
    return contours
end

"""
Create outlines for final consonant component
"""
function create_final_component(
    char::Char,
    x::Int16,
    y::Int16,
    width::Int16,
    height::Int16,
    stroke_width::Int16
)::Vector{Vector{Tuple{Int16, Int16, Bool}}}
    grid_size = GlyphConstants.GRID_DIVISIONS
    cell_width = width ÷ grid_size
    cell_height = height ÷ grid_size
    
    strokes = get_final_strokes(char)
    
    contours = Vector{Vector{Tuple{Int16, Int16, Bool}}}()
    for stroke in strokes
        points = map(point -> (
            Int16(x + point[1] * cell_width),
            Int16(y + point[2] * cell_height),
            true
        ), stroke)
        push!(contours, create_stroke_contour(points, stroke_width))
    end
    
    return contours
end

"""
Create a complete syllable glyph
"""
function create_syllable_glyph(initial::Char, vowel::Char, final::Union{Char, Nothing})::Glyph
    em_size = Int16(FontConstants.DEFAULT_EM_SQUARE)
    margin = Int16(floor(em_size * GlyphConstants.MARGIN_RATIO))
    usable_space = em_size - 2margin
    
    # Calculate component sizes
    initial_height = Int16(floor(usable_space * GlyphConstants.INITIAL_HEIGHT_RATIO))
    vowel_height = Int16(floor(usable_space * GlyphConstants.VOWEL_HEIGHT_RATIO))
    final_height = Int16(floor(usable_space * GlyphConstants.FINAL_HEIGHT_RATIO))
    
    # Calculate stroke width
    stroke_width = Int16(floor(usable_space * GlyphConstants.STROKE_WIDTH_RATIO))
    
    # Create metrics
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
    
    # Generate components
    components = Vector{Vector{Vector{Tuple{Int16, Int16, Bool}}}}()
    
    # Add initial consonant
    push!(components, create_initial_component(
        initial,
        margin,
        em_size - margin - initial_height,
        usable_space,
        initial_height,
        stroke_width
    ))
    
    # Add vowel
    push!(components, create_vowel_component(
        vowel,
        margin + initial_height,
        em_size - margin - vowel_height,
        usable_space - initial_height,
        vowel_height,
        stroke_width
    ))
    
    # Add final consonant if present
    if final !== nothing
        push!(components, create_final_component(
            final,
            margin,
            margin,
            usable_space,
            final_height,
            stroke_width
        ))
    end
    
    # Combine components into outline
    outline = combine_components(components, margin, em_size - margin)
    
    return Glyph(metrics, outline)
end

# Include stroke pattern definitions
include("stroke_patterns.jl")

# Export public interface
export create_syllable_glyph, create_notdef_glyph, GlyphConstants