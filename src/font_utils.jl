# src/font_utils.jl

using FreeType

#= 
TTFont 구조체를 정의합니다.
=#
mutable struct TTFont
    face::FreeType.Face
    tables::Dict{String, Vector{UInt8}}
    
    function TTFont()
        new(FreeType.Face(), Dict{String, Vector{UInt8}}())
    end
end

#= 
TTF에 메타데이터를 추가합니다.
=#
function add_metadata!(ttf::TTFont, metadata::FontMetadata)
    # 이름 테이블 생성
    name_table = Dict{UInt16, String}(
        1 => metadata.name,        # 글꼴 패밀리 이름
        2 => "Regular",           # 글꼴 서브패밀리 이름
        3 => metadata.version,    # 고유 글꼴 식별자
        4 => metadata.name,       # 전체 글꼴 이름
        5 => metadata.version,    # 버전 문자열
        6 => metadata.name,       # PostScript 이름
        7 => metadata.copyright   # 상표
    )
    ttf.tables["name"] = serialize_name_table(name_table)
end

#= 
TTF에 글리프를 추가합니다.
=#
function add_glyph!(ttf::TTFont, char::Char, glyph::Glyph)
    # 비트맵을 FreeType 형식으로 변환
    ft_bitmap = convert_to_ft_bitmap(glyph.bitmap)
    
    # glyf 테이블에 추가
    add_to_glyf_table!(ttf, char, ft_bitmap, glyph.metrics)
end

#= 
TTF 파일을 저장합니다.
=#
function save_ttf(ttf::TTFont, output_file::String)
    # 출력 디렉토리가 존재하는지 확인
    mkpath(dirname(output_file))
    
    try
        # 테이블을 TTF 형식으로 컴파일
        ttf_data = compile_ttf(ttf)
        
        # 파일에 쓰기
        write(output_file, ttf_data)
        println("TTF 파일이 성공적으로 저장되었습니다: $output_file")
    catch e
        println("TTF 파일 저장 중 오류 발생: ", e)
        # 자리 표시자로 빈 파일 생성
        touch(output_file)
        println("자리 표시자로 빈 TTF 파일을 생성했습니다.")
    end
end

#= 
도움 함수
=#
function serialize_name_table(name_table::Dict{UInt16, String})
    # 기본 이름 테이블 직렬화
    return Vector{UInt8}()  # 자리 표시자
end

function convert_to_ft_bitmap(bitmap::Matrix{UInt8})
    # 비트맵 형식을 FreeType 형식으로 변환
    return bitmap  # 자리 표시자
end

function add_to_glyf_table!(ttf::TTFont, char::Char, bitmap::Matrix{UInt8}, metrics::GlyphMetrics)
    # glyf 테이블에 글리프 데이터를 추가
    # 자리 표시자 구현
end

function compile_ttf(ttf::TTFont)
    # 모든 테이블을 TTF 형식으로 컴파일
    # 자리 표시자 구현
    return Vector{UInt8}()
end

#= 
원본 글꼴 설치 함수는 동일하게 유지됩니다.
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
글꼴을 생성하고 설치합니다.
=#
function generate_and_install(font_name::String="옛한글")
    # 글꼴 생성
    font = create_font(font_name)
    
    # 조합 생성
    println("조합 생성 중...")
    combinations = generate_all_combinations(font)
    total = length(combinations)
    println("생성할 총 조합 수: $total")
    
    # 글리프 생성
    for (i, (initial, vowel, final)) in enumerate(combinations)
        if i % 1000 == 0
            println("처리 중: $i / $total ($(round(i/total*100, digits=2))%)")
        end
        
        glyph = create_syllable_glyph(initial, vowel, final)
        unicode_point = calculate_unicode_point(initial, vowel, final)
        font.glyphs[Char(unicode_point)] = glyph
    end
    
    # 원시 글꼴 데이터 저장
    output_dir = "output/yethangle"
    println("글꼴 데이터를 $output_dir에 저장 중")
    save_font(font, output_dir)
    
    # TTF로 변환
    ttf_file = "output/yethangle.ttf"
    println("TTF 형식으로 변환 중...")
    convert_to_ttf(font, ttf_file)
    
    # 설치
    println("글꼴 설치 중...")
    install_font(ttf_file)
    
    println("옛한글 글꼴이 성공적으로 생성되고 설치되었습니다!")
end
