class XcodeTarget
    attr_accessor :sdks
    attr_accessor :schemes
    attr_accessor :configs
    attr_accessor :workspace

    def self.workspace= workspace
        @@workspace = workspace
    end

    def self.test(dict)
        self.new(dict).run_tests
    end

    def initialize(dict = {})
        @workspace = @@workspace
        @configs = ["Debug", "Release"]

        dict.each do |key, val|
            instance_variable_set("@#{key}", val)
        end
    end

    def run_tests
        require_defined :workspace, :schemes, :sdks, :configs
        @schemes.product(@sdks, @configs){|params| test_specific(*params)}
    end

private
    @@workspace = nil

    def require_defined *attrs
        attrs.each do |a|
            val = send(a)
            fail "Undefined: '#{a}'" if val == nil
            fail "No values provided for: '#{a}'" if val.is_a?(Array) && val.count == 0
        end
    end

    def xctool(*args)
        system("xctool", "-workspace", @workspace, *args)
    end

    def test_specific(scheme, sdk, config)
        exit(1) unless xctool("-scheme", scheme, "-sdk", sdk, "-configuration", config, "test", "-freshInstall")
    end
end

if __FILE__ == $0 && ARGV[0] != nil then
    XcodeTarget.instance_eval(ARGV[0])
end
