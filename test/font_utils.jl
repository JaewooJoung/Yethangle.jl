# src/font_utils.jl

using FreeType
using ProgressMeter
using Dates

"""
Binary writer for TTF files with proper file handling
"""
mutable struct BinaryWriter
    io::IOStream
    temp_path::String
    final_path::String
    
    function BinaryWriter(path::String)
        temp_path = path * ".tmp"
        io = open(temp_path, "w+b")  # Binary mode
        new(io, temp_path, path)
    end
end

"""
Write binary data with proper byte order handling
"""
function write_binary(io::IO, value::Number)
    write(io, hton(value))  # Convert to network byte order
end

"""
Create head table with proper font information
"""
function create_head_table()::Vector{UInt8}
    buf = IOBuffer()
    
    # Version 1.0
    write_binary(buf, UInt32(FontConstants.TTF_VERSION))
    
    # Font revision
    write_binary(buf, UInt32(FontConstants.TTF_VERSION))
    
    # CheckSum adjustment (to be filled later)
    write_binary(buf, UInt32(0))
    
    # Magic number for checksum calculation
    write_binary(buf, UInt32(0x5F0F3CF5))
    
    # Flags
    write_binary(buf, UInt16(0b0000000000000011))  # y-value of 0 references baseline
    
    # Units per EM
    write_binary(buf, UInt16(FontConstants.DEFAULT_EM_SQUARE))
    
    # Created and modified timestamps
    current_time = time()
    mac_epoch = Dates.datetime2unix(DateTime(1904, 1, 1))
    mac_timestamp = UInt32(floor(current_time - mac_epoch))
    write_binary(buf, UInt32(mac_timestamp))  # Created
    write_binary(buf, UInt32(mac_timestamp))  # Modified
    
    # Font bounding box
    write_binary(buf, Int16(-100))  # xMin
    write_binary(buf, Int16(-100))  # yMin
    write_binary(buf, Int16(1100))  # xMax
    write_binary(buf, Int16(1100))  # yMax
    
    # Font characteristics
    write_binary(buf, UInt16(0))    # Mac style
    write_binary(buf, UInt16(7))    # Lowest rec PPEM
    write_binary(buf, Int16(2))     # Font direction hint
    write_binary(buf, Int16(1))     # Index to loc format (long)
    write_binary(buf, Int16(0))     # Glyph data format
    
    take!(buf)
end

"""
Create maxp table with glyph count information
"""
function create_maxp_table(num_glyphs::Int)::Vector{UInt8}
    buf = IOBuffer()
    
    write_binary(buf, UInt32(0x00010000))  # Version 1.0
    write_binary(buf, UInt16(num_glyphs))  # numGlyphs
    write_binary(buf, UInt16(4))           # maxPoints
    write_binary(buf, UInt16(2))           # maxContours
    write_binary(buf, UInt16(0))           # maxCompositePoints
    write_binary(buf, UInt16(0))           # maxCompositeContours
    write_binary(buf, UInt16(2))           # maxZones
    write_binary(buf, UInt16(0))           # maxTwilightPoints
    write_binary(buf, UInt16(0))           # maxStorage
    write_binary(buf, UInt16(0))           # maxFunctionDefs
    write_binary(buf, UInt16(0))           # maxInstructionDefs
    write_binary(buf, UInt16(0))           # maxStackElements
    write_binary(buf, UInt16(0))           # maxSizeOfInstructions
    write_binary(buf, UInt16(0))           # maxComponentElements
    write_binary(buf, UInt16(0))           # maxComponentDepth
    
    take!(buf)
end

"""
Create hhea table with horizontal metrics
"""
function create_hhea_table()::Vector{UInt8}
    buf = IOBuffer()
    
    write_binary(buf, UInt32(0x00010000))  # Version 1.0
    write_binary(buf, Int16(800))          # Ascender
    write_binary(buf, Int16(-200))         # Descender
    write_binary(buf, Int16(200))          # LineGap
    write_binary(buf, UInt16(1000))        # advanceWidthMax
    write_binary(buf, Int16(-100))         # minLeftSideBearing
    write_binary(buf, Int16(-100))         # minRightSideBearing
    write_binary(buf, Int16(1000))         # xMaxExtent
    write_binary(buf, Int16(1))            # caretSlopeRise
    write_binary(buf, Int16(0))            # caretSlopeRun
    write_binary(buf, Int16(0))            # caretOffset
    write_binary(buf, Int16(0))            # reserved1
    write_binary(buf, Int16(0))            # reserved2
    write_binary(buf, Int16(0))            # reserved3
    write_binary(buf, Int16(0))            # reserved4
    write_binary(buf, Int16(0))            # metricDataFormat
    write_binary(buf, UInt16(1))           # numberOfHMetrics
    
    take!(buf)
end

"""
Create vhea table with vertical metrics
"""
function create_vhea_table()::Vector{UInt8}
    buf = IOBuffer()
    
    write_binary(buf, UInt32(0x00010000))  # Version 1.0
    write_binary(buf, Int16(800))          # vertTypoAscender
    write_binary(buf, Int16(-200))         # vertTypoDescender
    write_binary(buf, Int16(200))          # vertTypoLineGap
    write_binary(buf, Int16(1000))         # advanceHeightMax
    write_binary(buf, Int16(-100))         # minTopSideBearing
    write_binary(buf, Int16(-100))         # minBottomSideBearing
    write_binary(buf, Int16(1000))         # yMaxExtent
    write_binary(buf, Int16(0))            # caretSlopeRise
    write_binary(buf, Int16(1))            # caretSlopeRun
    write_binary(buf, Int16(0))            # caretOffset
    write_binary(buf, Int16(0))            # reserved1
    write_binary(buf, Int16(0))            # reserved2
    write_binary(buf, Int16(0))            # reserved3
    write_binary(buf, Int16(0))            # reserved4
    write_binary(buf, Int16(0))            # metricDataFormat
    write_binary(buf, UInt16(1))           # numOfLongVerMetrics
    
    take!(buf)
end

"""
Create metrics tables
"""
function create_hmtx_table(num_glyphs::Int)::Vector{UInt8}
    buf = IOBuffer()
    
    for _ in 1:num_glyphs
        write_binary(buf, UInt16(1000))    # advanceWidth
        write_binary(buf, Int16(0))        # leftSideBearing
    end
    
    take!(buf)
end

function create_vmtx_table(num_glyphs::Int)::Vector{UInt8}
    buf = IOBuffer()
    
    for _ in 1:num_glyphs
        write_binary(buf, UInt16(1000))    # advanceHeight
        write_binary(buf, Int16(0))        # topSideBearing
    end
    
    take!(buf)
end

"""
Create post table with PostScript information
"""
function create_post_table()::Vector{UInt8}
    buf = IOBuffer()
    
    write_binary(buf, UInt32(0x00030000))  # Version 3.0
    write_binary(buf, Int32(0))            # italicAngle
    write_binary(buf, Int16(-100))         # underlinePosition
    write_binary(buf, Int16(50))           # underlineThickness
    write_binary(buf, UInt32(1))           # isFixedPitch
    write_binary(buf, UInt32(0))           # minMemType42
    write_binary(buf, UInt32(0))           # maxMemType42
    write_binary(buf, UInt32(0))           # minMemType1
    write_binary(buf, UInt32(0))           # maxMemType1
    
    take!(buf)
end

"""
Create location table
"""
function create_loca_table(ttf::TTFont)::Vector{UInt8}
    buf = IOBuffer()
    
    offset = 0
    write_binary(buf, UInt32(0))  # First glyph starts at 0
    
    for loc in ttf.locations
        offset += ((loc + 3) & ~3)  # Align to 4 bytes
        write_binary(buf, UInt32(offset))
    end
    
    take!(buf)
end

"""
Create name table with font metadata
"""
function add_metadata!(ttf::TTFont, metadata::FontMetadata)
    name_records = [
        (0, metadata.copyright),
        (1, metadata.name),
        (2, "Regular"),
        (3, "$(metadata.name)-Regular"),
        (4, metadata.name),
        (5, "Version " * metadata.version),
        (6, "$(metadata.name)-Regular")
    ]
    
    buf = IOBuffer()
    
    # Format selector
    write_binary(buf, UInt16(0))
    
    # Number of name records
    write_binary(buf, UInt16(length(name_records)))
    
    # Offset to string storage
    write_binary(buf, UInt16(6 + 12 * length(name_records)))
    
    # Calculate string offsets and encode strings
    string_data = IOBuffer()
    offset = 0
    encoded_strings = []
    
    for (name_id, text) in name_records
        # Convert to UTF-16BE
        utf16_data = transcode(UInt16, text)
        encoded = Vector{UInt8}()
        for c in utf16_data
            push!(encoded, UInt8(c >> 8))
            push!(encoded, UInt8(c & 0xFF))
        end
        push!(encoded_strings, (name_id, encoded, offset))
        write(string_data, encoded)
        offset += length(encoded)
    end
    
    # Write name records
    for (name_id, encoded, offset) in encoded_strings
        write_binary(buf, UInt16(3))       # Platform ID (Windows)
        write_binary(buf, UInt16(1))       # Encoding ID (Unicode)
        write_binary(buf, UInt16(0x409))   # Language ID (US English)
        write_binary(buf, UInt16(name_id))
        write_binary(buf, UInt16(length(encoded)))
        write_binary(buf, UInt16(offset))
    end
    
    # Write string data
    write(buf, take!(string_data))
    
    ttf.tables["name"] = take!(buf)
end

"""
Update required tables before saving
"""
function update_required_tables!(ttf::TTFont)
    ttf.tables["maxp"] = create_maxp_table(ttf.num_glyphs)
    ttf.tables["hhea"] = create_hhea_table()
    ttf.tables["hmtx"] = create_hmtx_table(ttf.num_glyphs)
    ttf.tables["head"] = create_head_table()
    ttf.tables["loca"] = create_loca_table(ttf)
    ttf.tables["post"] = create_post_table()
    ttf.tables["vhea"] = create_vhea_table()
    ttf.tables["vmtx"] = create_vmtx_table(ttf.num_glyphs)
    
    # Create CMAP table
    chars = collect(keys(ttf.glyph_indices))
    ttf.tables["cmap"] = create_cmap_format12_table(chars, ttf.glyph_indices)
end

"""
Calculate checksum for TTF data
"""
function calc_checksum(data::Vector{UInt8})::UInt32
    # Pad data to 4-byte boundary
    padded = copy(data)
    padding_needed = (4 - (length(padded) % 4)) % 4
    append!(padded, zeros(UInt8, padding_needed))
    
    checksum = UInt32(0)
    for i in 1:4:length(padded)
        value = (UInt32(padded[i]) << 24) |
                (UInt32(padded[i+1]) << 16) |
                (UInt32(padded[i+2]) << 8) |
                UInt32(padded[i+3])
        checksum = (checksum + value) & 0xFFFFFFFF
    end
    
    return checksum
end

"""
Generate TTF file from font data
"""
function generate_ttf(font::YethangleFont, output_file::String)
    ttf = TTFont()
    progress = Progress(length(font.glyphs), 1, "Generating TTF...")
    
    try
        # Add metadata
        add_metadata!(ttf, font.metadata)
        
        # Add .notdef glyph
        add_glyph!(ttf, '\0', font.glyphs['\0'], 0)
        
        # Add all other glyphs
        for (i, (char, glyph)) in enumerate(font.glyphs)
            if char == '\0'
                continue
            end
            
            if i % 1000 == 0
                update!(progress, i)
            end
            
            glyph_id = get!(font.glyph_indices, char, ttf.next_glyph_id)
            ttf.next_glyph_id += 1
            add_glyph!(ttf, char, glyph, glyph_id)
        end
        
        finish!(progress)
        
        # Save TTF file
        println("Saving TTF file...")
        save_ttf(ttf, output_file)
        println("TTF file saved successfully: $output_file")
        
    catch e
        @error "Failed to generate TTF" exception=e
        rethrow(e)
    end
end

# src/font_utils.jl

# ... (previous code remains the same)

"""
Save TTF file with proper error handling
"""
function save_ttf(ttf::TTFont, output_file::String)
    writer = nothing
    temp_file = output_file * ".tmp"
    
    try
        # Update required tables
        update_required_tables!(ttf)
        
        # Create output directory
        mkpath(dirname(output_file))
        
        # Initialize binary writer
        writer = BinaryWriter(output_file)
        
        # Write TTF data
        write_ttf_data(writer, ttf)
        
        # Close writer and move file to final location
        close(writer)
        
        return true
    catch e
        # Clean up on error
        if writer !== nothing
            close(writer.io)
            isfile(temp_file) && rm(temp_file)
        end
        @error "Failed to save TTF file" exception=e
        rethrow(e)
    end
end

"""
Write TTF data with checksums
"""
function write_ttf_data(writer::BinaryWriter, ttf::TTFont)
    # Sort tables for consistent output
    sorted_tables = sort(collect(ttf.tables))
    num_tables = length(sorted_tables)
    
    # Calculate header and directory sizes
    header_size = 12
    directory_size = 16 * num_tables
    offset = header_size + directory_size
    
    # Write TTF header
    write_binary(writer.io, UInt32(0x00010000))  # sfnt version 1.0
    write_binary(writer.io, UInt16(num_tables))
    
    # Calculate search range values
    entry_selector = floor(Int, log2(num_tables))
    search_range = (1 << entry_selector) * 16
    range_shift = (num_tables * 16) - search_range
    
    write_binary(writer.io, UInt16(search_range))
    write_binary(writer.io, UInt16(entry_selector))
    write_binary(writer.io, UInt16(range_shift))
    
    # First pass: write table directory
    current_offset = offset
    directory_entries = []
    file_checksum = UInt32(0)
    
    for (tag, data) in sorted_tables
        # Validate data
        if length(data) > FontConstants.MAX_TABLE_SIZE
            throw(ArgumentError("Table '$tag' exceeds maximum size"))
        end
        
        # Calculate checksum
        checksum = calc_checksum(data)
        file_checksum = (file_checksum + checksum) & 0xFFFFFFFF
        
        # Write table record
        tag_bytes = Vector{UInt8}(tag)
        while length(tag_bytes) < 4
            push!(tag_bytes, UInt8(0x20))
        end
        
        for byte in tag_bytes
            write(writer.io, byte)
        end
        
        write_binary(writer.io, UInt32(checksum))
        write_binary(writer.io, UInt32(current_offset))
        write_binary(writer.io, UInt32(length(data)))
        
        push!(directory_entries, (current_offset, data))
        current_offset += ((length(data) + 3) & ~3)  # Align to 4 bytes
    end
    
    # Second pass: write table data
    for (_, data) in directory_entries
        # Write table data
        write(writer.io, data)
        
        # Add padding to 4-byte boundary
        padding = (4 - (length(data) % 4)) % 4
        for _ in 1:padding
            write(writer.io, UInt8(0))
        end
        
        # Update checksum with padding
        if padding > 0
            padding_checksum = calc_checksum(zeros(UInt8, padding))
            file_checksum = (file_checksum + padding_checksum) & 0xFFFFFFFF
        end
    end
    
    # Update head table's checksum adjustment
    checksum_adjustment = (0xB1B0AFBA - file_checksum) & 0xFFFFFFFF
    
    # Save the current position
    current_pos = position(writer.io)
    
    # Find and update head table checksum
    seekstart(writer.io)
    num_tables = read(writer.io, UInt16)
    seek(writer.io, 12)  # Skip to directory
    
    for _ in 1:num_tables
        tag = String(read(writer.io, 4))
        skip(writer.io, 4)  # Skip checksum
        offset = read(writer.io, UInt32)
        skip(writer.io, 4)  # Skip length
        
        if tag == "head" || rstrip(tag) == "head"
            seek(writer.io, Int(offset) + 8)  # Skip to checkSumAdjustment field
            write_binary(writer.io, checksum_adjustment)
            break
        end
    end
    
    # Restore position
    seek(writer.io, current_pos)
end

"""
Update head table checksum
"""
function update_head_checksum(file_path::String, checksum_adjustment::UInt32)
    open(file_path, "r+b") do io
        # Find head table
        seekstart(io)
        num_tables = read(io, UInt16)
        seek(io, 12)  # Skip to directory
        
        for _ in 1:num_tables
            tag = String(read(io, 4))
            skip(io, 4)  # Skip checksum
            offset = read(io, UInt32)
            skip(io, 4)  # Skip length
            
            if tag == "head" || rstrip(tag) == "head"
                seek(io, Int(offset) + 8)  # Skip to checkSumAdjustment field
                write(io, hton(checksum_adjustment))
                break
            end
        end
    end
end

"""
Create CMAP format 12 (Unicode full repertoire) table
"""
function create_cmap_format12_table(chars::Vector{Char}, glyph_indices::Dict{Char, Int})::Vector{UInt8}
    buf = IOBuffer()
    
    # Table header
    write_binary(buf, UInt16(0))  # version
    write_binary(buf, UInt16(2))  # numTables (format 4 and 12)
    
    # Record offsets
    format4_offset = 4 + (8 * 2)  # header + 2 encoding records
    
    # Write encoding records
    # Format 4 (BMP)
    write_binary(buf, UInt16(3))      # platformID (Windows)
    write_binary(buf, UInt16(1))      # encodingID (Unicode BMP)
    write_binary(buf, UInt32(format4_offset))
    
    # Format 12 (Full Unicode)
    write_binary(buf, UInt16(3))      # platformID (Windows)
    write_binary(buf, UInt16(10))     # encodingID (Unicode full repertoire)
    write_binary(buf, UInt32(0))      # offset placeholder
    
    # Create character groups
    sorted_chars = sort(chars)
    groups = create_cmap_groups(sorted_chars, glyph_indices)
    
    # Write format 4 subtable
    format4_start = position(buf)
    write_format4_subtable(buf, groups, glyph_indices)
    
    # Write format 12 subtable
    format12_offset = position(buf)
    seek(buf, 20)  # Go back to format 12 offset
    write_binary(buf, UInt32(format12_offset))
    seek(buf, format12_offset)
    
    write_format12_subtable(buf, groups, glyph_indices)
    
    take!(buf)
end

"""
Create character mapping groups
"""
function create_cmap_groups(chars::Vector{Char}, glyph_indices::Dict{Char, Int})
    groups = []
    if !isempty(chars)
        start_char = first(chars)
        prev_char = start_char
        start_glyph = glyph_indices[start_char]
        
        for char in chars[2:end]
            if Int(char) != Int(prev_char) + 1 || 
               glyph_indices[char] != glyph_indices[prev_char] + 1
                # End current group and start new one
                push!(groups, (start_char, prev_char, start_glyph))
                start_char = char
                start_glyph = glyph_indices[char]
            end
            prev_char = char
        end
        # Add final group
        push!(groups, (start_char, prev_char, start_glyph))
    end
    return groups
end

"""
Write format 4 (BMP) subtable
"""
function write_format4_subtable(buf::IOBuffer, groups::Vector{Tuple}, glyph_indices::Dict{Char, Int})
    subtable_start = position(buf)
    segCount = length(groups) + 1  # Add 1 for required last segment
    
    # Write format 4 header
    write_binary(buf, UInt16(4))           # format
    write_binary(buf, UInt16(0))           # length (placeholder)
    write_binary(buf, UInt16(0))           # language
    write_binary(buf, UInt16(segCount * 2))  # segCountX2
    
    # Calculate searchRange values
    searchRange = 2 * (1 << floor(Int, log2(segCount)))
    entrySelector = floor(Int, log2(searchRange/2))
    rangeShift = 2 * segCount - searchRange
    
    write_binary(buf, UInt16(searchRange))
    write_binary(buf, UInt16(entrySelector))
    write_binary(buf, UInt16(rangeShift))
    
    # Write endCount[]
    for (_, end_char, _) in groups
        write_binary(buf, UInt16(Int(end_char)))
    end
    write_binary(buf, UInt16(0xFFFF))  # Required last segment
    
    # Write reservedPad
    write_binary(buf, UInt16(0))
    
    # Write startCount[]
    for (start_char, _, _) in groups
        write_binary(buf, UInt16(Int(start_char)))
    end
    write_binary(buf, UInt16(0xFFFF))  # Last segment
    
    # Write idDelta[]
    for (start_char, _, start_glyph) in groups
        delta = (start_glyph - Int(start_char)) & 0xFFFF
        write_binary(buf, Int16(delta))
    end
    write_binary(buf, Int16(1))  # Last segment
    
    # Write idRangeOffset[] (all zeros for our simple mapping)
    for _ in 1:segCount
        write_binary(buf, UInt16(0))
    end
    
    # Update subtable length
    subtable_length = position(buf) - subtable_start
    seek(buf, subtable_start + 2)
    write_binary(buf, UInt16(subtable_length))
    seek(buf, position(buf))
end

"""
Write format 12 (full Unicode) subtable
"""
function write_format12_subtable(buf::IOBuffer, groups::Vector{Tuple}, glyph_indices::Dict{Char, Int})
    subtable_start = position(buf)
    
    # Write format 12 header
    write_binary(buf, UInt16(12))          # format
    write_binary(buf, UInt16(0))           # reserved
    write_binary(buf, UInt32(0))           # length (placeholder)
    write_binary(buf, UInt32(0))           # language
    write_binary(buf, UInt32(length(groups)))  # numGroups
    
    # Write groups
    for (start_char, end_char, start_glyph) in groups
        write_binary(buf, UInt32(Int(start_char)))  # startCharCode
        write_binary(buf, UInt32(Int(end_char)))    # endCharCode
        write_binary(buf, UInt32(start_glyph))      # startGlyphID
    end
    
    # Update subtable length
    subtable_length = position(buf) - subtable_start
    seek(buf, subtable_start + 4)
    write_binary(buf, UInt32(subtable_length))
    seek(buf, position(buf))
end

# Export public functions
export add_metadata!, add_glyph!, save_ttf, generate_ttf