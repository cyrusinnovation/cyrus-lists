class ArchivesController < ApplicationController

  def index
    @list = List.find(params[:list_id])

    respond_to do |format|
      format.js do
        new_job = GmailService.enqueue(@list.name)
        @meta_id = new_job.meta_id
      end
      format.html
    end
  end

  def poll_for_changes
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Invalid Path" }

      format.js do
        @list = List.find(params[:list_id])
        if @archive_emails = Rails.cache.read(@list.name)
          @job_status = true
          flash.now[:notice] = "Messages Loaded!"
          return
        end

        @meta_id = params[:meta_id]
        @job = GmailService.get_meta(@meta_id)

        if @job
          @job_status = check_job_status
          if @job_status
            @archive_emails = get_result
          end
          Rails.cache.write(@list.name, @archive_emails, :expires_in => 1.day)
          if @archive_emails
            flash.now[:notice] = "Messages Loaded!"
          end
        else
          redirect_to root_path, notice: "Invalid Path"
        end # if @job
      end # format.js
    end # respond_to
  end


  private

  def check_job_status
    @job.succeeded?
  end

  def get_result
    @job.result
  end
end
