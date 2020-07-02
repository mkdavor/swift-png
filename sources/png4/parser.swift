//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/. 
    
extension PNG 
{
    public 
    struct Percentmille:AdditiveArithmetic, ExpressibleByIntegerLiteral
    {
        public 
        var points:Int 
        
        public static 
        let zero:Self = 0
        
        public 
        init<T>(_ points:T) where T:BinaryInteger
        {
            self.points = .init(points)
        }
        
        public 
        init(integerLiteral:Int)
        {
            self.init(integerLiteral)
        }
        
        public static 
        func + (lhs:Self, rhs:Self) -> Self 
        {
            .init(lhs.points + rhs.points)
        }
        public static 
        func += (lhs:inout Self, rhs:Self) 
        {
            lhs.points += rhs.points
        }
        public static 
        func - (lhs:Self, rhs:Self) -> Self 
        {
            .init(lhs.points - rhs.points)
        }
        public static 
        func -= (lhs:inout Self, rhs:Self) 
        {
            lhs.points -= rhs.points
        }
    }
    
    public 
    enum Format 
    {
        public 
        enum Pixel 
        {
            case v1
            case v2 
            case v4 
            case v8 
            case v16 
            
            case rgb8 
            case rgb16 
            
            case indexed1
            case indexed2
            case indexed4
            case indexed8 
            
            case va8 
            case va16 
            
            case rgba8 
            case rgba16 
        }
        
        // can’t use these in the enum cases because they are `internal` only
        typealias RGB<T>  = (r:T, g:T, b:T)
        typealias RGBA<T> = (r:T, g:T, b:T, a:T)
        
        case v1      (                                                background:   UInt8?,                       key:   UInt8?                      )
        case v2      (                                                background:   UInt8?,                       key:   UInt8?                      )
        case v4      (                                                background:   UInt8?,                       key:   UInt8?                      )
        case v8      (                                                background:   UInt8?,                       key:   UInt8?                      )
        case v16     (                                                background:   UInt16?,                      key:   UInt16?                     )
        
        case rgb8    (palette:[(r:UInt8, g:UInt8, b:UInt8         )], background:(r:UInt8,  g:UInt8,  b:UInt8 )?, key:(r:UInt8,  g:UInt8,  b:UInt8 )?)
        case rgb16   (palette:[(r:UInt8, g:UInt8, b:UInt8         )], background:(r:UInt16, g:UInt16, b:UInt16)?, key:(r:UInt16, g:UInt16, b:UInt16)?)
        
        case indexed1(palette:[(r:UInt8, g:UInt8, b:UInt8, a:UInt8)], background:    Int?                                                            )
        case indexed2(palette:[(r:UInt8, g:UInt8, b:UInt8, a:UInt8)], background:    Int?                                                            )
        case indexed4(palette:[(r:UInt8, g:UInt8, b:UInt8, a:UInt8)], background:    Int?                                                            )
        case indexed8(palette:[(r:UInt8, g:UInt8, b:UInt8, a:UInt8)], background:    Int?                                                            )
        
        case va8     (                                                background:   UInt8?                                                           )
        case va16    (                                                background:   UInt16?                                                          )
        
        case rgba8   (palette:[(r:UInt8, g:UInt8, b:UInt8         )], background:(r:UInt8,  g:UInt8,  b:UInt8 )?                                     )
        case rgba16  (palette:[(r:UInt8, g:UInt8, b:UInt8         )], background:(r:UInt16, g:UInt16, b:UInt16)?                                     )
    }
}
extension PNG.Format.Pixel 
{
    @inlinable
    public
    var hasColor:Bool
    {
        switch self 
        {
        case .v1, .v2, .v4, .v8, .v16, .va8, .va16:
            return false 
        case .rgb8, .rgb16, .indexed1, .indexed2, .indexed4, .indexed8, .rgba8, .rgba16:
            return true 
        }
    }
    @inlinable
    public
    var hasAlpha:Bool
    {
        switch self 
        {
        case .v1, .v2, .v4, .v8, .v16, .rgb8, .rgb16, 
            .indexed1, .indexed2, .indexed4, .indexed8:
            return false 
        case .va8, .va16, .rgba8, .rgba16:
            return true 
        }
    }
    
    @inlinable
    var volume:Int
    {
        self.depth * self.channels
    }
    
    @inlinable
    public
    var channels:Int
    {
        switch self
        {
        case .v1, .v2, .v4, .v8, .v16,
            .indexed1, .indexed2, .indexed4, .indexed8:     return 1
        case .va8,   .va16:                                 return 2
        case .rgb8,  .rgb16:                                return 3
        case .rgba8, .rgba16:                               return 4
        }
    }
    
    @inlinable
    public
    var depth:Int 
    {
        switch self 
        {
        case    .v1,          .indexed1:                    return  1
        case    .v2,          .indexed2:                    return  2
        case    .v4,          .indexed4:                    return  4
        case    .v8,  .rgb8,  .indexed8, .va8,  .rgba8:     return  8
        case    .v16, .rgb16,            .va16, .rgba16:    return 16
        }
    }
    
    @inlinable
    public
    var sampleDepth:Int 
    {
        switch self 
        {
        case    .v1:                                        return  1
        case    .v2:                                        return  2
        case    .v4:                                        return  4
        case    .indexed1, .indexed2, .indexed4, .indexed8, 
                .v8,  .rgb8,  .va8,  .rgba8:                return  8
        case    .v16, .rgb16, .va16, .rgba16:               return 16
        }
    }
    
    static 
    func recognize(code:(depth:UInt8, type:UInt8)) -> Self?
    {
        switch code
        {
        case ( 1, 0):   return .v1
        case ( 2, 0):   return .v2
        case ( 4, 0):   return .v4
        case ( 8, 0):   return .v8
        case (16, 0):   return .v16
        
        case ( 8, 2):   return .rgb8
        case (16, 2):   return .rgb16
        
        case ( 1, 3):   return .indexed1
        case ( 2, 3):   return .indexed2
        case ( 4, 3):   return .indexed4
        case ( 8, 3):   return .indexed8
        
        case ( 8, 4):   return .va8
        case (16, 4):   return .va16
        
        case ( 8, 6):   return .rgba8
        case (16, 6):   return .rgba16
        
        default:        return nil
        }
    }
}
extension PNG.Format 
{
    @inlinable
    public
    var pixel:Pixel
    {
        switch self
        {
        case .v1:       return .v1
        case .v2:       return .v2
        case .v4:       return .v4
        case .v8:       return .v8
        case .v16:      return .v16
        case .rgb8:     return .rgb8
        case .rgb16:    return .rgb16
        case .indexed1: return .indexed1
        case .indexed2: return .indexed2
        case .indexed4: return .indexed4
        case .indexed8: return .indexed8
        case .va8:      return .va8
        case .va16:     return .va16
        case .rgba8:    return .rgba8
        case .rgba16:   return .rgba16
        }
    }
    
    public static 
    func recognize(pixel:PNG.Format.Pixel, palette:PNG.Palette?, 
        background:PNG.Background?, transparency:PNG.Transparency?) -> Self?
    {
        let format:Self 
        switch pixel 
        {
        case .v1, .v2, .v4, .v8, .v16:
            guard palette == nil 
            else 
            {
                // palette not allowed for grayscale format
                return nil 
            }
            let b:UInt16?, 
                k:UInt16?
            switch background 
            {
            case nil: 
                b = nil 
            case .v(let v)?: 
                guard Int.init(v) < 1 << pixel.depth
                else 
                {
                    return nil 
                }
                b = v
            default: 
                return nil 
            }
            switch transparency 
            {
            case nil:
                k = nil 
            case .v(let v)?: 
                guard Int.init(v) < 1 << pixel.depth
                else 
                {
                    return nil 
                }
                k = v
            default: 
                return nil 
            }
            
            switch pixel 
            {
            case .v1:
                format = .v1(background: b.map(UInt8.init(_:)), key: k.map(UInt8.init(_:)))
            case .v2:
                format = .v2(background: b.map(UInt8.init(_:)), key: k.map(UInt8.init(_:)))
            case .v4:
                format = .v4(background: b.map(UInt8.init(_:)), key: k.map(UInt8.init(_:)))
            case .v8:
                format = .v8(background: b.map(UInt8.init(_:)), key: k.map(UInt8.init(_:)))
            case .v16:
                format = .v16(background: b,                    key: k)
            default:
                fatalError("unreachable")
            }
        
        case .rgb8, .rgb16:
            let palette:[RGB<UInt8>] = palette?.entries ?? []
            let b:RGB<UInt16>?, 
                k:RGB<UInt16>?
            switch background 
            {
            case nil: 
                b = nil 
            case .rgb(let v)?: 
                b = v
            default: 
                return nil 
            }
            switch transparency 
            {
            case nil:
                k = nil 
            case .rgb(let v)?: 
                k = v
            default: 
                return nil 
            }
            
            switch pixel 
            {
            case .rgb8:
                format = .rgb8(palette: palette, 
                    background: b.map{ (.init($0.r), .init($0.g), .init($0.b)) }, 
                    key:        k.map{ (.init($0.r), .init($0.g), .init($0.b)) })
            case .rgb16:
                format = .rgb16(palette: palette, background: b, key: k)
            default:
                fatalError("unreachable")
            }
        
        case .indexed1, .indexed2, .indexed4, .indexed8:
            guard let solid:PNG.Palette = palette, 
                solid.count <= 1 << pixel.depth 
            else 
            {
                return nil 
            }
            let b:Int? 
            switch background 
            {
            case nil:
                b = nil 
            case .palette(index: let i):
                guard i < solid.count 
                else 
                {
                    return nil 
                }
                b = i
            default: 
                return nil 
            }
            let palette:[RGBA<UInt8>]
            switch transparency 
            {
            case nil:
                palette =          solid.map        { (  $0.r,   $0.g,   $0.b, .max) }
            case .palette(alpha: let alpha):
                precondition(alpha.count <= solid.count)
                palette =      zip(solid, alpha).map{ ($0.0.r, $0.0.g, $0.0.b, $0.1) } + 
                    solid.dropFirst(alpha.count).map{ (  $0.r,   $0.g,   $0.b, .max) }
            default: 
                return nil 
            }
            
            switch pixel  
            {
            case .indexed1: 
                format = .indexed1(palette: palette, background: b)
            case .indexed2: 
                format = .indexed2(palette: palette, background: b)
            case .indexed4: 
                format = .indexed4(palette: palette, background: b)
            case .indexed8: 
                format = .indexed8(palette: palette, background: b)
            default:
                fatalError("unreachable")
            }
        
        case .va8, .va16:
            guard palette == nil, transparency == nil 
            else 
            {
                // palette/chroma-key not allowed for grayscale-alpha format
                return nil 
            }
            let b:UInt16?
            switch background 
            {
            case nil:           b = nil 
            case .v(let v)?:    b = v
            default: 
                return nil 
            }
            
            switch pixel 
            {
            case .va8:
                format = .va8(background: b.map(UInt8.init(_:)))
            case .va16:
                format = .va16(background: b)
            default:
                fatalError("unreachable")
            }
        
        case .rgba8, .rgba16:
            guard transparency == nil 
            else 
            {
                // chroma key not allowed for rgba format
                return nil 
            }
            let palette:[RGB<UInt8>] = palette?.entries ?? []
            let b:RGB<UInt16>?
            switch background 
            {
            case nil:           b = nil 
            case .rgb(let v)?:  b = v
            default: 
                return nil 
            }
            
            switch pixel 
            {
            case .rgba8:
                format = .rgba8(palette: palette, 
                    background: b.map{ (.init($0.r), .init($0.g), .init($0.b)) })
            case .rgba16:
                format = .rgba16(palette: palette, background: b)
            default:
                fatalError("unreachable")
            }
        }
        
        return format 
    }
}

extension PNG 
{
    public 
    enum ParsingError:Swift.Error 
    {
        case truncatedHeader(Int, minimum:Int)
        case invalidHeaderColorCode(depth:UInt8, type:UInt8)
        case invalidHeaderCompressionCode(UInt8)
        case invalidHeaderFilterCode(UInt8)
        case invalidHeaderInterlacingCode(UInt8)
        case invalidHeaderSize((x:Int, y:Int))
        
        case unexpectedPalette(pixel:PNG.Format.Pixel)
        case invalidPaletteSampleCount(Int)
        case invalidPaletteEntryCount(Int, expected:ClosedRange<Int>)
        
        case unexpectedTransparency(pixel:PNG.Format.Pixel)
        case invalidTransparencyChunkLength(Int, expected:Int)
        case invalidChromaKeySample(UInt16, expected:ClosedRange<UInt16>)
        case invalidTransparencyPaletteEntryCount(Int, expected:ClosedRange<Int>)
        
        case unexpectedBackground
        case invalidBackgroundChunkLength(Int, expected:Int)
        case invalidBackgroundSample(UInt16, expected:ClosedRange<UInt16>)
        case invalidBackgroundPaletteEntryIndex(Int, expected:ClosedRange<Int>)
        
        case unexpectedHistogram
        case invalidHistogramChunkLength(Int)
        case invalidHistogramBinCount(Int, expected:Int)
        
        case invalidGammaChunkLength(Int)
        
        case invalidChromaticityChunkLength(Int)
        
        case invalidColorRenderingChunkLength(Int)
        case invalidColorRenderingCode(UInt8)
        
        case invalidSignificantBitsChunkLength(Int, expected:Int)
        case invalidSignificantBitsSamplePrecision(Int, expected:ClosedRange<Int>)
        
        case invalidPhysicalDimensionsChunkLength(Int)
        case invalidPhysicalDimensionsDensityUnitCode(UInt8)
        
        case truncatedSuggestedPalette(Int, minimum:Int)
        case invalidSuggestedPaletteChunkLength(Int, offset:Int, stride:Int)
        case missingSuggestedPaletteName
        case invalidSuggestedPaletteName 
        case invalidSuggestedPaletteDepthCode(UInt8)
        
        case invalidTimeModifiedChunkLength(Int)
        case invalidTimeModifiedTime(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int)
        
        case missingTextKeyword
        case invalidTextKeyword
    }
}
extension PNG 
{
    public 
    struct Header
    {
        public
        let size:(x:Int, y:Int), 
            pixel:PNG.Format.Pixel, 
            interlaced:Bool
    }
}
extension PNG.Header 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self 
    {
        guard data.count == 13
        else
        {
            throw PNG.ParsingError.truncatedHeader(data.count, minimum: 13)
        }
        
        guard let pixel:PNG.Format.Pixel = .recognize(code: (data[8], data[9]))
        else
        {
            throw PNG.ParsingError.invalidHeaderColorCode(depth: data[8], type: data[9])
        }

        // validate other fields
        guard data[10] == 0
        else
        {
            throw PNG.ParsingError.invalidHeaderCompressionCode(data[10])
        }
        guard data[11] == 0
        else
        {
            throw PNG.ParsingError.invalidHeaderFilterCode(data[11])
        }

        let interlaced:Bool
        switch data[12]
        {
        case 0:
            interlaced = false
        case 1:
            interlaced = true
        default:
            throw PNG.ParsingError.invalidHeaderInterlacingCode(data[12])
        }
        
        let size:(x:Int, y:Int) = 
        (
            data.load(bigEndian: UInt32.self, as: Int.self, at: 0),
            data.load(bigEndian: UInt32.self, as: Int.self, at: 4)
        )
        // validate size 
        guard size.x > 0, size.y > 0 
        else 
        {
            throw PNG.ParsingError.invalidHeaderSize(size)
        }

        return .init(size: size, pixel: pixel, interlaced: interlaced)
    }
}

extension PNG 
{
    public 
    struct Palette 
    {
        let entries:[(r:UInt8, g:UInt8, b:UInt8)]
    }
}
extension PNG.Palette 
{
    public static 
    func parse(_ data:[UInt8], pixel:PNG.Format.Pixel) throws -> Self
    {
        guard pixel.hasColor
        else
        {
            throw PNG.ParsingError.unexpectedPalette(pixel: pixel)
        }
        
        let (count, remainder):(Int, Int) = data.count.quotientAndRemainder(dividingBy: 3)
        guard remainder == 0
        else
        {
            throw PNG.ParsingError.invalidPaletteSampleCount(data.count)
        }

        // check number of palette entries
        let maximum:Int = 1 << pixel.depth
        guard 1 ... maximum ~= count 
        else
        {
            throw PNG.ParsingError.invalidPaletteEntryCount(count, expected: 1 ... maximum)
        }

        return .init(entries: (0 ..< count).map
        {
            (i:Int) -> (r:UInt8, g:UInt8, b:UInt8) in 
            (data[3 * i], data[3 * i + 1], data[3 * i + 2])
        })
    }
}
extension PNG.Palette:RandomAccessCollection 
{
    public 
    var startIndex:Int 
    {
        self.entries.startIndex
    }
    public 
    var endIndex:Int 
    {
        self.entries.endIndex
    }
    public 
    subscript(index:Int) -> (r:UInt8, g:UInt8, b:UInt8) 
    {
        self.entries[index]
    }
}

extension PNG 
{
    public 
    enum Transparency 
    {
        case palette(alpha:[UInt8])
        case rgb(key:(r:UInt16, g:UInt16, b:UInt16))
        case v(key:UInt16)
    }
}
extension PNG.Transparency 
{
    public static 
    func parse(_ data:[UInt8], pixel:PNG.Format.Pixel, palette:PNG.Palette?) 
        throws -> Self
    {
        let max:UInt16 = .init(1 << pixel.depth - 1 as Int)
        switch pixel 
        {
        case .v1, .v2, .v4, .v8, .v16:
            guard data.count == 2 
            else 
            {
                throw PNG.ParsingError.invalidTransparencyChunkLength(data.count, 
                    expected: 2)
            }
            
            let v:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 0)
            guard v <= max 
            else 
            {
                throw PNG.ParsingError.invalidChromaKeySample(v, expected: 0 ... max)
            }
            return .v(key: v)
        
        case .rgb8, .rgb16:
            guard data.count == 6 
            else 
            {
                throw PNG.ParsingError.invalidTransparencyChunkLength(data.count, 
                    expected: 6)
            }
            
            let r:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 0),
                g:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 2),
                b:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 4)
            guard r <= max, g <= max, b <= max 
            else 
            {
                throw PNG.ParsingError.invalidChromaKeySample(Swift.max(r, g, b), 
                    expected: 0 ... max)
            }
            return .rgb(key: (r, g, b))
        
        case .indexed1, .indexed2, .indexed4, .indexed8:
            guard let palette:PNG.Palette = palette 
            else 
            {
                throw PNG.ParsingError.unexpectedTransparency(pixel: pixel)
            }
            guard data.count <= palette.count  
            else 
            {
                throw PNG.ParsingError.invalidTransparencyPaletteEntryCount(data.count, 
                    expected: 1 ... palette.count)
            }
            return .palette(alpha: data)
        
        case .va8, .va16, .rgba8, .rgba16:
            throw PNG.ParsingError.unexpectedTransparency(pixel: pixel)
        }
    }
}

extension PNG 
{
    public 
    enum Background 
    {
        case palette(index:Int)
        case rgb((r:UInt16, g:UInt16, b:UInt16))
        case v(UInt16)
    }
}
extension PNG.Background 
{
    public static 
    func parse(_ data:[UInt8], pixel:PNG.Format.Pixel, palette:PNG.Palette?) 
        throws -> Self
    {
        let max:UInt16 = .init(1 << pixel.depth - 1 as Int)
        switch pixel 
        {
        case .v1, .v2, .v4, .v8, .v16, .va8, .va16:
            guard data.count == 2 
            else 
            {
                throw PNG.ParsingError.invalidBackgroundChunkLength(data.count, 
                    expected: 2)
            }
            
            let v:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 0)
            guard v <= max 
            else 
            {
                throw PNG.ParsingError.invalidBackgroundSample(v, expected: 0 ... max)
            }
            return .v(v)
        
        case .rgb8, .rgb16, .rgba8, .rgba16:
            guard data.count == 6 
            else 
            {
                throw PNG.ParsingError.invalidBackgroundChunkLength(data.count, 
                    expected: 6)
            }
            
            let r:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 0),
                g:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 2),
                b:UInt16 = data.load(bigEndian: UInt16.self, as: UInt16.self, at: 4)
            for v:UInt16 in [r, g, b] where v > max
            {
                throw PNG.ParsingError.invalidBackgroundSample(v, expected: 0 ... max)
            }
            
            return .rgb((r, g, b))
        
        case .indexed1, .indexed2, .indexed4, .indexed8:
            guard let palette:PNG.Palette = palette 
            else 
            {
                throw PNG.ParsingError.unexpectedBackground
            }
            guard data.count == 1
            else 
            {
                throw PNG.ParsingError.invalidBackgroundChunkLength(data.count, 
                    expected: 1)
            }
            let index:Int = .init(data[0])
            guard index < palette.count
            else 
            {
                throw PNG.ParsingError.invalidBackgroundPaletteEntryIndex(index, 
                    expected: 0 ... palette.count - 1)
            }
            return .palette(index: index)
        }
    }
}

extension PNG 
{
    public 
    struct Histogram 
    {
        private 
        var frequencies:[UInt16]
    }
}
extension PNG.Histogram 
{
    public static 
    func parse(_ data:[UInt8], pixel:PNG.Format.Pixel, palette:PNG.Palette) 
        throws -> Self
    {
        switch pixel 
        {
        case .v1, .v2, .v4, .v8, .v16, .va8, .va16, .rgb8, .rgb16, .rgba8, .rgba16:
            throw PNG.ParsingError.unexpectedHistogram
        
        case .indexed1, .indexed2, .indexed4, .indexed8:
            guard data.count & 1 == 0 
            else 
            {
                // must have parity 2
                throw PNG.ParsingError.invalidHistogramChunkLength(data.count)
            }
            guard data.count >> 1 == palette.count
            else 
            {
                throw PNG.ParsingError.invalidHistogramBinCount(data.count >> 1, 
                    expected: palette.count)
            }
            return .init(frequencies: (0 ..< data.count >> 1).map 
            {
                data.load(bigEndian: UInt16.self, as: UInt16.self, at: $0 << 1)
            })
        }
    }
}

extension PNG 
{
    public 
    struct Gamma 
    {
        public 
        let pcm:Percentmille 
    }
}
extension PNG.Gamma 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard data.count == 4
        else 
        {
            throw PNG.ParsingError.invalidGammaChunkLength(data.count)
        }
        
        return .init(pcm: .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 0)))
    }
}

extension PNG 
{
    public 
    struct Chromaticity  
    {
        public 
        let w:(x:Percentmille, y:Percentmille), 
            r:(x:Percentmille, y:Percentmille), 
            g:(x:Percentmille, y:Percentmille), 
            b:(x:Percentmille, y:Percentmille)
    }
}
extension PNG.Chromaticity 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard data.count == 32
        else 
        {
            throw PNG.ParsingError.invalidChromaticityChunkLength(data.count)
        }
        
        return .init(
            w: 
            (
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at:  0)),
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at:  4))
            ),
            r: 
            (
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at:  8)),
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 12))
            ),
            g: 
            (
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 16)),
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 20))
            ),
            b: 
            (
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 24)),
                .init(data.load(bigEndian: UInt32.self, as: Int.self, at: 28))
            ))
    }
}

extension PNG 
{
    public 
    enum ColorRendering
    {
        case perceptual 
        case relative 
        case saturation 
        case absolute 
    }
}
extension PNG.ColorRendering 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard data.count == 1
        else 
        {
            throw PNG.ParsingError.invalidColorRenderingChunkLength(data.count)
        }
        
        switch data[0] 
        {
        case 0:     return .perceptual 
        case 1:     return .relative 
        case 2:     return .saturation 
        case 3:     return .absolute 
        default:    throw PNG.ParsingError.invalidColorRenderingCode(data[0])
        }
    }
}

extension PNG 
{
    public 
    struct SignificantBits 
    {
        public 
        let bits:(r:Int, g:Int, b:Int, a:Int)
    }
}
extension PNG.SignificantBits 
{
    public static 
    func parse(_ data:[UInt8], pixel:PNG.Format.Pixel) throws -> Self
    {
        let arity:Int = (pixel.hasColor ? 3 : 1) + (pixel.hasAlpha ? 1 : 0)
        guard data.count == arity 
        else 
        {
            throw PNG.ParsingError.invalidSignificantBitsChunkLength(data.count, 
                expected: arity)
        }
        
        switch pixel 
        {
        case .v1, .v2, .v4, .v8, .v16:
            let v:Int = .init(data[0])
            guard 1 ... pixel.sampleDepth ~= v 
            else 
            {
                throw PNG.ParsingError.invalidSignificantBitsSamplePrecision(v, 
                    expected: 1 ... pixel.sampleDepth)
            }
            return .init(bits: (v, v, v, pixel.sampleDepth))
        
        case .rgb8, .rgb16, .indexed1, .indexed2, .indexed4, .indexed8:
            let r:Int = .init(data[0]), 
                g:Int = .init(data[1]), 
                b:Int = .init(data[2])
            for v:Int in [r, g, b] where !(1 ... pixel.sampleDepth ~= v)
            {
                throw PNG.ParsingError.invalidSignificantBitsSamplePrecision(v, 
                    expected: 1 ... pixel.sampleDepth)
            }
            return .init(bits: (r, g, b, pixel.sampleDepth))
        
        case .va8, .va16:
            let v:Int = .init(data[0]), 
                a:Int = .init(data[1])
            for v:Int in [v, a] where !(1 ... pixel.sampleDepth ~= v)
            {
                throw PNG.ParsingError.invalidSignificantBitsSamplePrecision(v, 
                    expected: 1 ... pixel.sampleDepth)
            }
            return .init(bits: (v, v, v, a))
        
        case .rgba8, .rgba16:
            let r:Int = .init(data[0]), 
                g:Int = .init(data[1]), 
                b:Int = .init(data[2]),
                a:Int = .init(data[3])
            for v:Int in [r, g, b, a] where !(1 ... pixel.sampleDepth ~= v)
            {
                throw PNG.ParsingError.invalidSignificantBitsSamplePrecision(v, 
                    expected: 1 ... pixel.sampleDepth)
            }
            return .init(bits: (r, g, b, a))
        }
    }
}

extension PNG 
{
    public 
    struct ColorProfile
    {
        public 
        let name:String 
        public 
        let profile:[UInt8]
    }
}
extension PNG.ColorProfile 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        fatalError("unsupported")
    }
}


extension PNG 
{
    public 
    struct PhysicalDimensions
    {
        public 
        enum Unit 
        {
            case meter
        }
        
        public 
        let density:(x:Int, y:Int, unit:Unit?)
    }
}
extension PNG.PhysicalDimensions 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard data.count == 9
        else 
        {
            throw PNG.ParsingError.invalidPhysicalDimensionsChunkLength(data.count)
        }
        
        let x:Int = data.load(bigEndian: UInt32.self, as: Int.self, at: 0),
            y:Int = data.load(bigEndian: UInt32.self, as: Int.self, at: 4)
        
        let unit:Unit?
        switch data[8]
        {
        case 0:     unit = nil 
        case 1:     unit = .meter 
        default:    throw PNG.ParsingError.invalidPhysicalDimensionsDensityUnitCode(data[8])
        }
        
        return .init(density: (x, y, unit))
    }
}

extension PNG 
{
    public 
    struct SuggestedPalette 
    {
        public 
        enum Entries 
        {
            case rgba8( [(color:(r:UInt8,  g:UInt8,  b:UInt8,  a:UInt8),  frequency:UInt16)])
            case rgba16([(color:(r:UInt16, g:UInt16, b:UInt16, a:UInt16), frequency:UInt16)])
        }
        
        public 
        let name:String 
        public 
        var entries:Entries 
    }
}
extension PNG.SuggestedPalette 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard let offset:Int = data.firstIndex(of: 0)
        else 
        {
            throw PNG.ParsingError.missingSuggestedPaletteName
        }
        // validate keyword 
        guard let name:String = PNG.Text.validate(keyword: data.prefix(offset))
        else 
        {
            throw PNG.ParsingError.invalidSuggestedPaletteName
        }
        
        guard offset + 1 < data.count 
        else 
        {
            throw PNG.ParsingError.truncatedSuggestedPalette(data.count, 
                minimum: offset + 2)
        }
        
        switch data[offset + 1] 
        {
        case 8:
            let (count, remainder):(Int, Int) = 
                (data.count - offset - 2).quotientAndRemainder(dividingBy: 6)
            guard remainder == 0 
            else 
            {
                throw PNG.ParsingError.invalidSuggestedPaletteChunkLength(data.count,  
                    offset: offset + 2, stride: 6)
            }
            
            return .init(name: name, entries: .rgba8((0 ..< count).map 
            {
                (i:Int) -> (color:(r:UInt8, g:UInt8, b:UInt8, a:UInt8), frequency:UInt16) in
                (
                    (
                        data[offset + 2 + 6 * i    ],
                        data[offset + 2 + 6 * i + 1],
                        data[offset + 2 + 6 * i + 2],
                        data[offset + 2 + 6 * i + 3]
                    ), 
                    data.load(bigEndian: UInt16.self, as: UInt16.self, 
                        at:  offset + 2 + 6 * i + 4)
                )
            }))
        
        case 16:
            let (count, remainder):(Int, Int) = 
                (data.count - offset - 2).quotientAndRemainder(dividingBy: 10)
            guard remainder == 0 
            else 
            {
                throw PNG.ParsingError.invalidSuggestedPaletteChunkLength(data.count,  
                    offset: offset + 2, stride: 10)
            }
            
            return .init(name: name, entries: .rgba16((0 ..< count).map 
            {
                (i:Int) -> (color:(r:UInt16, g:UInt16, b:UInt16, a:UInt16), frequency:UInt16) in
                (
                    (
                        data.load(bigEndian: UInt16.self, as: UInt16.self, 
                            at: offset + 2 + 10 * i    ),
                        data.load(bigEndian: UInt16.self, as: UInt16.self, 
                            at: offset + 2 + 10 * i + 1),
                        data.load(bigEndian: UInt16.self, as: UInt16.self, 
                            at: offset + 2 + 10 * i + 2),
                        data.load(bigEndian: UInt16.self, as: UInt16.self, 
                            at: offset + 2 + 10 * i + 3)
                    ), 
                    data.load(bigEndian: UInt16.self, as: UInt16.self, 
                        at:     offset + 2 + 10 * i + 4)
                )
            }))
        
        default:
            throw PNG.ParsingError.invalidSuggestedPaletteDepthCode(data[offset + 1])
        }
    }
}

extension PNG 
{
    public 
    struct TimeModified 
    {
        public 
        let year:Int, 
            month:Int, 
            day:Int, 
            hour:Int, 
            minute:Int, 
            second:Int
    }
}
extension PNG.TimeModified 
{
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        guard data.count == 7 
        else 
        {
            throw PNG.ParsingError.invalidTimeModifiedChunkLength(data.count)
        }
        
        let year:Int    = data.load(bigEndian: UInt16.self, as: Int.self, at: 0), 
            month:Int   = .init(data[2]), 
            day:Int     = .init(data[3]), 
            hour:Int    = .init(data[4]), 
            minute:Int  = .init(data[5]), 
            second:Int  = .init(data[6]) 
        
        guard   1 ... 12 ~= month, 
                1 ... 31 ~= day, 
                0 ... 23 ~= hour, 
                0 ... 59 ~= minute, 
                0 ... 60 ~= second 
        else 
        {
            throw PNG.ParsingError.invalidTimeModifiedTime(year: year, month: month, 
                day: day, hour: hour, minute: minute, second: second)
        }
        
        return .init(year: year, month: month, day: day, 
            hour: hour, minute: minute, second: second)
    }
}

extension PNG 
{
    public 
    struct Text 
    {
        public 
        let compressed:Bool 
        public 
        let keyword:(english:String, localized:String), 
            language:String
        public 
        let content:String
    }
}
extension PNG.Text 
{
    static 
    func validate<C>(keyword prefix:C) -> String? 
        where C:Collection, C.Index == Int, C.Element == UInt8 
    {
        guard (prefix.allSatisfy{ 32 ... 126 ~= $0 || 161 ... 255 ~= 0 })
        else 
        {
            return nil
        }
        
        let keyword:String = .init(prefix.map{ Character.init(Unicode.Scalar.init($0)) })
        guard   !prefix.reversed().starts(with: [32]), // no trailing spaces 
                !prefix.starts(           with: [32])  // no leading spaces 
        else 
        {
            return nil
        }
        for i:Int in prefix.indices where prefix[i] == 32 
        {
            // don’t need to check index bounds because we already verified 
            // it has no trailing spaces
            guard prefix[i + 1] != 32 
            else 
            {
                return nil
            }
        }
        return keyword
    }
    public static 
    func parse(_ data:[UInt8]) throws -> Self
    {
        fatalError("unsupported")
    }
    public static 
    func parse(latin1 data:[UInt8]) throws -> Self
    {
        guard let offset:Int = data.firstIndex(of: 0)
        else 
        {
            throw PNG.ParsingError.missingTextKeyword
        }
        // validate keyword 
        guard let keyword:String = Self.validate(keyword: data.prefix(offset))
        else 
        {
            throw PNG.ParsingError.invalidTextKeyword
        }
        
        // if the next byte is also null, the chunk uses compression
        if offset + 1 < data.endIndex, data[offset + 1] == 0
        {
            fatalError("unsupported")
        }
        else 
        {
            return .init(compressed: false, 
                keyword: (keyword, keyword), 
                language: "en", 
                content: .init(data.dropFirst(offset + 1).map 
                {
                    Character.init(Unicode.Scalar.init($0))
                }))
        }
    }
}
