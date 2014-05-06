require 'storage'
require 'yast'

module YStorage
  class PrepShrink
    include Yast::Logger
    include YaST::Arch

    def runlog cmd
      result = Yast::SCR.Execute(Yast::Path.new(".target.bash_output"), cmd)
      log.info "run command #{cmd} with result #{result.inspect}"
    end

    def run
      if Arch.board_chrp   
        prep_size = 8192
        parted = "parted -s -a minimal"
        target_map = Storage.GetTargetMap
        partitions = target_map.reduce([]) do |parts, pair|
          parts.concat(pair[1]["partitions"] || [])
        end

        partitions.each do |partition|
          if [0x41, 0x108].include? partition["fsid"] && partition["size_k"] > prep_size
            runlog "#{parted} #{device} resize #{part_nr} #{prep_size}k"
          end
        end
      end

      return :auto
    end
  end
end
