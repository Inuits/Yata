class ProjectsController < ApplicationController
  before_filter :admin_required
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
      format.json  { render :json => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    if params[:year].nil?
      @year= Time.now.year
    else
      @year= params[:year].to_i
    end
    @timesheets = Timesheet.find_all_by_project_id(@project.id)



    @total_time = 0
    @datas = {}
    @sum = Array.new()

    @timesheets.each do |t|
      @total_time += t.total_normal + 1.5*t.total_rate2 + 2*t.total_rate3
      if @datas[t.year].nil?
        @datas[t.year] = {}
        @sum[t.year] = Array.new(12,0.0)
      end
      if @datas[t.year][t.authuser.fullname].nil?
        @datas[t.year][t.authuser.fullname] = Array.new(12,0.0)
      end
      @datas[t.year][t.authuser.fullname][t.month-1] += t.total_normal + 1.5 * t.total_rate2 + 2 * t.total_rate3
      @sum[t.year][t.month-1] += t.total_normal + 1.5 * t.total_rate2 + 2 * t.total_rate3
    end


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
