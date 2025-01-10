# test/runtests.jl
using Test
using Yethangle
using Dates

@testset "Yethangle.jl" begin
    @testset "FontMetadata" begin
        @test begin
            # Test valid metadata creation
            metadata = FontMetadata(
                "Test Font",
                "1.0.0",
                "Test Copyright",
                1000
            )
            metadata.name == "Test Font" &&
            metadata.version == "1.0.0" &&
            metadata.copyright == "Test Copyright" &&
            metadata.em_square == 1000
        end

        # Test invalid EM square values
        @test_throws EmSquareError FontMetadata("Test", "1.0", "Test", 0)
        @test_throws EmSquareError FontMetadata("Test", "1.0", "Test", -100)
        @test_throws EmSquareError FontMetadata("Test", "1.0", "Test", 20000)

        # Test invalid version string
        @test_throws ArgumentError FontMetadata("Test", "invalid", "Test", 1000)

        # Test name length limit
        @test_throws ArgumentError FontMetadata("T" ^ 64, "1.0", "Test", 1000)
    end

    @testset "GlyphMetrics" begin
        @test begin
            # Test valid metrics creation
            metrics = GlyphMetrics(
                1000,    # width
                1000,    # height
                0,       # horiBearingX
                800,     # horiBearingY
                1000,    # horiAdvance
                0,       # vertBearingX
                0,       # vertBearingY
                1000     # vertAdvance
            )
            metrics.width == 1000 &&
            metrics.height == 1000 &&
            metrics.horiBearingX == 0 &&
            metrics.horiBearingY == 800 &&
            metrics.horiAdvance == 1000 &&
            metrics.vertBearingX == 0 &&
            metrics.vertBearingY == 0 &&
            metrics.vertAdvance == 1000
        end

        # Test invalid dimensions
        @test_throws MetricsError GlyphMetrics(0, 1000, 0, 800, 1000, 0, 0, 1000)
        @test_throws MetricsError GlyphMetrics(1000, 0, 0, 800, 1000, 0, 0, 1000)
        @test_throws MetricsError GlyphMetrics(-100, 1000, 0, 800, 1000, 0, 0, 1000)

        # Test bearing limits
        @test_throws MetricsError GlyphMetrics(1000, 1000, -20000, 800, 1000, 0, 0, 1000)
        @test_throws MetricsError GlyphMetrics(1000, 1000, 0, 20000, 1000, 0, 0, 1000)
    end

    @testset "GlyphOutline" begin
        @test begin
            # Test valid outline creation
            points = [(0, 0, true), (1000, 0, true), (1000, 1000, true), (0, 1000, true)]
            outline = GlyphOutline(
                [points],  # contours
                0,        # xmin
                0,        # ymin
                1000,     # xmax
                1000      # ymax
            )
            outline.xmin == 0 &&
            outline.ymin == 0 &&
            outline.xmax == 1000 &&
            outline.ymax == 1000 &&
            length(outline.contours) == 1 &&
            length(outline.contours[1]) == 4
        end

        # Test empty contours
        @test_throws GlyphError GlyphOutline([], 0, 0, 1000, 1000)
        @test_throws GlyphError GlyphOutline([Vector{Tuple{Int16, Int16, Bool}}()], 0, 0, 1000, 1000)

        # Test invalid bounds
        @test_throws GlyphError GlyphOutline(
            [[(0, 0, true), (1000, 1000, true)]],
            1000, 0, 0, 1000  # xmax < xmin
        )
        @test_throws GlyphError GlyphOutline(
            [[(0, 0, true), (1000, 1000, true)]],
            0, 1000, 1000, 0  # ymax < ymin
        )
    end

    @testset "Glyph Creation" begin
        @test begin
            # Test valid glyph creation
            metrics = GlyphMetrics(1000, 1000, 0, 800, 1000, 0, 0, 1000)
            points = [(0, 0, true), (1000, 0, true), (1000, 1000, true), (0, 1000, true)]
            outline = GlyphOutline([points], 0, 0, 1000, 1000)
            glyph = Glyph(metrics, outline)
            
            glyph.metrics == metrics &&
            glyph.outline == outline
        end

        # Test metrics/outline mismatch
        @test_throws GlyphError begin
            metrics = GlyphMetrics(500, 500, 0, 800, 1000, 0, 0, 1000)
            points = [(0, 0, true), (1000, 0, true), (1000, 1000, true), (0, 1000, true)]
            outline = GlyphOutline([points], 0, 0, 1000, 1000)
            Glyph(metrics, outline)
        end
    end

    @testset "Unicode Point Calculation" begin
        @test begin
            # Test basic calculation
            point = calculate_unicode_point('ᄀ', 'ㅏ', nothing)
            0xE000 ≤ point ≤ 0xF8FF  # Should be in Private Use Area
        end

        @test begin
            # Test with final consonant
            point = calculate_unicode_point('ᄀ', 'ㅏ', 'ᆨ')
            0xE000 ≤ point ≤ 0xF8FF
        end

        # Test invalid characters
        @test_throws ArgumentError calculate_unicode_point('X', 'ㅏ', nothing)
        @test_throws ArgumentError calculate_unicode_point('ᄀ', 'X', nothing)
        @test_throws ArgumentError calculate_unicode_point('ᄀ', 'ㅏ', 'X')
    end

    @testset "Font Generation" begin
        mktempdir() do tmp_dir
            output_file = joinpath(tmp_dir, "test_font.ttf")
            
            @test begin
                # Test basic font generation
                font = create_font("Test Font")
                font.metadata.name == "Test Font"
            end

            @test begin
                # Test file generation
                generate_font("Test Font", output_file)
                isfile(output_file)
            end

            # Test file content (basic validation)
            @test begin
                file_size = filesize(output_file)
                file_size > 0
            end
        end
    end

    @testset "Error Handling" begin
        @test_throws ArgumentError create_font("")  # Empty font name
        @test_throws ArgumentError create_font("T" ^ 64)  # Too long font name

        mktempdir() do tmp_dir
            invalid_dir = joinpath(tmp_dir, "nonexistent", "subfolder")
            @test_throws SystemError generate_font(
                "Test Font",
                joinpath(invalid_dir, "test.ttf")
            )
        end
    end

    @testset "Table Generation" begin
        font = create_font("Test Font")
        ttf = TTFont()
        add_metadata!(ttf, font.metadata)

        @test haskey(ttf.tables, "name")
        
        # Add test glyph
        metrics = GlyphMetrics(1000, 1000, 0, 800, 1000, 0, 0, 1000)
        points = [(0, 0, true), (1000, 0, true), (1000, 1000, true), (0, 1000, true)]
        outline = GlyphOutline([points], 0, 0, 1000, 1000)
        glyph = Glyph(metrics, outline)
        
        add_glyph!(ttf, 'A', glyph, 1)
        
        @test ttf.num_glyphs > 0
        @test length(ttf.locations) > 0
    end

    @testset "Binary Writing" begin
        mktempdir() do tmp_dir
            output_file = joinpath(tmp_dir, "test_binary.ttf")
            
            writer = BinaryWriter(output_file)
            
            # Test basic binary writing
            write(writer.io, UInt32(0x12345678))
            write(writer.io, UInt16(0xABCD))
            
            close(writer)
            
            # Verify written data
            open(output_file, "r") do io
                @test read(io, UInt32) == 0x12345678
                @test read(io, UInt16) == 0xABCD
            end
        end
    end
end