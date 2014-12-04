class MathModel::Adapter::Mathematica < MathModel::Adapter
 
  def executable_prefix
    super("mathematica")
  end
  
  def execute(command, params, position = nil)
    result = ""
    pos = position || 2
    Dir.chdir(executable_prefix) do
      systemcall(command, params)
      File.open("sampled.json", "r") do |f|
        result = JSON.load(f)
      end
      File.delete("sampled.json")
    end
    #MathModel::Result.new(value: result.map {|arr| arr[pos]})
    PowderData::EmulatedPoints.new(points: result.map {|arr| arr[pos]})
  end
  
  
end