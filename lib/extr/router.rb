# this is the router of Extr for EXT Direct, implemented as rack middleware
#Rails.ProjectsController.getChildProject(1,function(r,e){
#alert(r);
#});
#Rails.ProjectsController.getChildProject(2,function(r,e){
#alert(r);
#});
#Rails.ProjectsController.getChildProject(3,function(r,e){
#alert(r);
#});

module Extr

 class Router
  def initialize(app, router_path)
   @app = app
   @router_path = router_path
  end

  def call(env)
   @env = env
   if ext_direct_request?
    body = []
    if form_data?
     p "form post"
     #todo implement form_posts
    else
     p "json post"
     r = ExtDirectJsonRequest.new(env)
     r.transactions.each do |t|
      body << (t.model_transaction? ? invoke_model_method(t) : invoke_controller_method(t))
     end
    end
    [200, { "Content-Type" => "application/json"}, ["#{body.to_json}"]]
   else
    @app.call(env)
   end
  end

  private

  def invoke_model_method(t)
   p "invoke model"
   unless t.data.nil?
    return_val = t.action.constantize.send(t.method)
    #return_val = action.constantize.send(method, *normalize_params_for(action,parameters))
   else
    return_val = t.action.constantize.send(t.method)
   end
  end

  def invoke_controller_method(t)
   result = {
    'type'    =>    'rpc',
    'tid'     =>    t.tid,
    'action'  =>    t.action,
    'method'  =>    t.method,
    'result' => ""
   }
   controller_path = Config.get_controller_path(t.action)
   request_env = @env.dup

   controller_request_env = @env.dup
   controller_request_env["PATH_INFO"] = "extr/#{controller_path}-#{t.method}/json"
   controller_request_env["REQUEST_URI"] = "extr/#{controller_path}-#{t.method}/json"

   begin
    status,headers,response=@app.call(controller_request_env)
    result['result'] = response ? response.body : ""
    result['result'] = ActiveSupport::JSON.decode(result['result'])
    result
   rescue => e
    if Rails.env.development?
     Rails.logger.error result['type'] = 'exception'
     Rails.logger.error result['message'] = e.message
     Rails.logger.error result['where'] = e.backtrace.join("\n")
     result["result"] = ""
    else
     result["result"] = {}
    end
     result
   end
  end

  def ext_direct_request?
   @env["PATH_INFO"].match("^#{@router_path}") && @env['REQUEST_METHOD']== "POST"
   #todo and params exist
  end

  def form_data?
   @env['rack.request.form_hash'] ? true : false
  end

 end
end

