class PdfViewerController < ApplicationController
  def show
    @filepath = '/' + params[:filepath].to_s + '.' + params[:format].to_s
    render :formats => 'html', :layout => false
  end

  def download
    @filepath = '/' + params[:filepath].to_s + '.' + params[:format].to_s
    send_file File.join(Rails.root, 'public',  @filepath), :disposition => 'attachment'
  end
end
