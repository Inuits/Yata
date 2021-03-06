class TimesheetsController < ApplicationController
  before_filter :login_required
  protect_from_forgery :except => [:show, :create_hour]

  # GET /timesheets
  # GET /timesheets.xml
  def index
    @timesheets = Timesheet.find_all_by_authuser_id(current_authuser, :order => "year DESC, month DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @timesheets }
      format.json  { render :json => @timesheets }
    end
  end

  # GET /timesheets/all
  # GET /timesheets/all.xml
  def all
    if logged_in? and current_authuser.admin
      if params[:year].nil?
        @year= Time.now.year
      else
        @year= params[:year].to_i
      end
      @timesheets = Timesheet.find_all_by_year(@year, :order => "year, month desc, authuser_id")
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @timesheets }
        format.json  { render :json => @timesheets }
      end
    else
      redirect_back_or_default('/')
    end
  end

  # GET /timesheets/1
  # GET /timesheets/1.xml
  def show
    @timesheet = Timesheet.find(params[:id])
    if not current_authuser.admin and @timesheet.authuser.id.to_i != current_authuser.id.to_i
      flash[:notice] = 'You are not allowed to view this timesheet.'
      redirect_to :root
      return
    end
    @hour = Hour.new
    @hour.day= Time.now.day
    @hour.normal= 8

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @timesheet.to_xml(:include => [ :hours ]) }
      format.json  { render :json => @timesheet.to_json(:include => [ @timesheet.hours ]) }
    end
  end

  # GET /timesheets/new
  # GET /timesheets/new.xml
  def new
    @timesheet = Timesheet.new
    @timesheet.month = Time.now.mon
    @timesheet.year = Time.now.year
    @projects = Project.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @timesheet }
      format.json  { render :json => @timesheet }
    end
  end

  # POST /timesheets/update_project_div
  def update_project_div
    if current_authuser.admin
      @projects = Project.find(:all, :order => :name, :conditions => ["customer_id = ?", params[:timesheet_customer_id]])
    else
      @projects = Project.find(:all, :order => :name, :conditions => ["name NOT LIKE '_closed_%' and customer_id = ?", params[:timesheet_customer_id]])
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /timesheets/1/edit
  def edit
    @timesheet = Timesheet.find(params[:id])
    if not current_authuser.admin and @timesheet.authuser.id.to_i != current_authuser.id.to_i
      flash[:notice] = 'You are not allowed to edit this timesheet.'
      redirect_to :root
      return
    end
    if current_authuser.admin
      @projects = Project.find(:all, :order => :name, :conditions => ["customer_id = ?", @timesheet.customer_id])
    else
      @projects = Project.find(:all, :order => :name, :conditions => ["name NOT LIKE '_closed_%' and customer_id = ?", @timesheet.customer_id])
    end
  end


  # POST /timesheets
  # POST /timesheets.xml
  # POST /timesheets.json
  def create
    puts params[:timesheet]
    @timesheet = Timesheet.new(params[:timesheet])
    if @timesheet.authuser_id == nil
      @timesheet.authuser_id = current_authuser.id
    end

    respond_to do |format|
      if @timesheet.save
        flash[:notice] = 'Timesheet was successfully created.'
        format.html { redirect_to(@timesheet) }
        format.xml  { render :xml => @timesheet, :status => :created, :location => @timesheet }
        format.json  { render :json => @timesheet, :status => :created, :location => @timesheet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @timesheet.errors, :status => :unprocessable_entity }
        format.json  { render :json => @timesheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /timesheets/1
  # PUT /timesheets/1.xml
  def update
    @timesheet = Timesheet.find(params[:id])
    if not current_authuser.admin and @timesheet.authuser.id.to_i != current_authuser.id.to_i
      flash[:notice] = 'You are not allowed to edit this timesheet.'
      redirect_to :root
      return
    end

    respond_to do |format|
      if @timesheet.update_attributes(params[:timesheet])
        flash[:notice] = 'Timesheet was successfully updated.'
        format.html { redirect_to(@timesheet) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @timesheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timesheets/1
  # DELETE /timesheets/1.xml
  def destroy
    @timesheet = Timesheet.find(params[:id])
    if not current_authuser.admin and @timesheet.authuser.id.to_i != current_authuser.id.to_i
      flash[:notice] = 'You are not allowed to destroy this timesheet.'
      redirect_to :root
      return
    end
    @timesheet.destroy

    respond_to do |format|
      format.html { redirect_to(timesheets_url) }
      format.xml  { head :ok }
    end
  end

  # POST /timesheets/create_hour
  # POST /timesheets/create_hour.xml
  # POST /timesheets/create_hour.json
  def create_hour
    @hour = Hour.new(params[:hour])
    @hour.timesheet_id= params[:id]

    respond_to do |format|
      if @hour.save
        format.html {render :partial => 'hour', :object => @hour}
        format.xml  { render :xml => @hour }
        format.json  { render :json => @hour }
      else
        format.html
        format.xml  { render :xml => @hour.errors, :status => :unprocessable_entity }
        format.json  { render :json => @hour.errors, :status => :unprocessable_entity }
      end
    end
  end

  def user
    @month= params[:month].to_i
    @year= params[:year].to_i

    @day = Array.new
    @timesheets= Timesheet.find_all_by_authuser_id_and_year_and_month(params[:id], @year, @month)

    for timesheet in @timesheets
      num= @timesheets.index(timesheet)
      @hours= Hour.find_all_by_timesheet_id(timesheet.id)

      for hour in @hours
        @day[hour.day] = Array.new(@timesheets.size) if @day[hour.day].nil?

        if @day[hour.day][num].nil?
          @day[hour.day][num]= Hash.new
        end
        if @day[hour.day][num]["normal"].nil?
          @day[hour.day][num]["normal"] = hour.normal unless hour.normal.nil?
        else
          @day[hour.day][num]["normal"] += hour.normal unless hour.normal.nil?
        end

        if @day[hour.day][num]["rate2"].nil?
          @day[hour.day][num]["rate2"] = hour.rate2 unless hour.rate2.nil?
        else
          @day[hour.day][num]["rate2"] += hour.rate2 unless hour.rate2.nil?
        end

        if @day[hour.day][num]["rate3"].nil?
          @day[hour.day][num]["rate3"] = hour.rate3 unless hour.rate3.nil?
        else
          @day[hour.day][num]["rate3"] += hour.rate3 unless hour.rate3.nil?
        end

        if @day[hour.day][num]["travel"].nil?
          @day[hour.day][num]["travel"] = hour.travel unless hour.travel.nil?
        else
          @day[hour.day][num]["travel"] += hour.travel unless hour.travel.nil?
        end
      end
    end
  end

end
