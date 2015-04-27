module Mixins
end
  
module AutoMixins
  
  def self.included(base)
    base.extend(ClassMethods)
  end 
  
  mattr_accessor :mixin_paths
  
  def self.mixin_lib_paths
    if @@mixin_paths.nil?
      @@mixin_paths = []
      # Setting up default mixin path
      @@mixin_paths << File.join(Rails.root, "lib", "mixins")
      
      Rails::Railtie::Configuration.eager_load_namespaces.each do |namespace|
        if namespace.to_s.match("::Engine")  
          
          root = namespace.root
          mixin_path = File.join(root, "lib", "mixins")
          if !Dir.glob(mixin_path).empty?
            @@mixin_paths << mixin_path
          end  
        end  
      end  
      
    end
    return @@mixin_paths  
  end   
  
  module ClassMethods
    
    def enable_auto_mixin!
      AutoMixins.mixin_lib_paths.each do |mixin_path|
        mixin_path = File.join(mixin_path, self.name.underscore)
        
        mixin_files = Dir.glob(File.join(mixin_path, "*.rb"))
        
        # getting the mixin target folder
        puts "Loading '#{self.name}' mixins from '#{mixin_path}'" if !mixin_files.empty?
        
        mixin_files.each do |file|
        
          require_dependency file
        
          # Building Module
          regexp  = Regexp.new("mixins\\/#{self.name.underscore}\\/.{1,}(?=\\.rb)")
          mod     = file.match(regexp).to_s.camelize.constantize  

          puts "found '#{mod.name}'"
        
          self.send(:include, mod)
        end  
      end  
      
    end  
    
  end  
  
end  

ActiveRecord::Base.send(:include, AutoMixins)