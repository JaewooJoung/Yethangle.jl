# src/font_utils.jl

#= 
글꼴을 TTF 형식으로 변환합니다.
=#
function convert_to_ttf(font::YethangleFont, output_file::String)
    ttf = TTFont()
    
    # 메타데이터 추가
    add_metadata!(ttf, font.metadata)
    
    # 글리프 추가
    for (char, glyph) in font.glyphs
        add_glyph!(ttf, char, glyph)
    end
    
    # TTF 파일 저장
    save_ttf(ttf, output_file)
end

#= 
시스템에 글꼴을 설치합니다.
=#
function install_font(ttf_file::String)
    @static if Sys.iswindows()
        fonts_dir = joinpath(ENV["WINDIR"], "Fonts")
        cp(ttf_file, joinpath(fonts_dir, basename(ttf_file)))
        run(`reg add "HKCU\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" /v "Yethangle (TrueType)" /t REG_SZ /d "$(basename(ttf_file))" /f`)
    elseif Sys.isapple()
        fonts_dir = expanduser("~/Library/Fonts")
        cp(ttf_file, joinpath(fonts_dir, basename(ttf_file)))
    else
        fonts_dir = expanduser("~/.local/share/fonts")
        mkpath(fonts_dir)
        cp(ttf_file, joinpath(fonts_dir, basename(ttf_file)))
        run(`fc-cache -f -v`)
    end
end

#= 
완전한 글꼴을 생성하고 설치합니다.
=#
function generate_and_install(font_name::String="옛한글")
    # 글꼴 생성
    font = create_font(font_name)
    
    # 조합 생성
    println("Generating combinations...")
    combinations = generate_all_combinations(font)
    total = length(combinations)
    println("Total combinations to generate: $total")
    
    # 글리프 생성
    for (i, (initial, vowel, final)) in enumerate(combinations)
        if i % 1000 == 0
            println("Processing $i of $total ($(round(i/total*100, digits=2))%)")
        end
        
        glyph = create_syllable_glyph(initial, vowel, final)
        unicode_point = calculate_unicode_point(initial, vowel, final)
        font.glyphs[Char(unicode_point)] = glyph
    end
    
    # 원시 글꼴 데이터 저장
    output_dir = "output/yethangle"
    println("Saving font data to $output_dir")
    save_font(font, output_dir)
    
    # TTF로 변환
    ttf_file = "output/yethangle.ttf"
    println("Converting to TTF format...")
    convert_to_ttf(font, ttf_file)
    
    # 설치
    println("Installing font...")
    install_font(ttf_file)
    
    println("Yethangle font successfully generated and installed!")
end
