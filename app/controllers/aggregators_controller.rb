class AggregatorsController < ApplicationController
  # GET /aggregators
  # GET /aggregators.xml
  def index
    @aggregators = Aggregator.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @aggregators }
    end
  end

  # GET /aggregators/1
  # GET /aggregators/1.xml
  def show
    @aggregator = Aggregator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @aggregator }
    end
  end

  # GET /aggregators/new
  # GET /aggregators/new.xml
  def new
    @aggregator = Aggregator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @aggregator }
    end
  end

  # GET /aggregators/1/edit
  def edit
    @aggregator = Aggregator.find(params[:id])
  end

  # POST /aggregators
  # POST /aggregators.xml
  def create
    @aggregator = Aggregator.new(params[:aggregator])

    respond_to do |format|
      if @aggregator.save
        flash[:notice] = 'Aggregator was successfully created.'
        format.html { redirect_to(@aggregator) }
        format.xml  { render :xml => @aggregator, :status => :created, :location => @aggregator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @aggregator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /aggregators/1
  # PUT /aggregators/1.xml
  def update
    @aggregator = Aggregator.find(params[:id])

    respond_to do |format|
      if @aggregator.update_attributes(params[:aggregator])
        flash[:notice] = 'Aggregator was successfully updated.'
        format.html { redirect_to(@aggregator) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @aggregator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /aggregators/1
  # DELETE /aggregators/1.xml
  def destroy
    @aggregator = Aggregator.find(params[:id])
    @aggregator.destroy

    respond_to do |format|
      format.html { redirect_to(aggregators_url) }
      format.xml  { head :ok }
    end
  end
end
