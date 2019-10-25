# frozen_string_literal: true

class CommentsController < ApplicationController
  respond_to :html, :js

  helper CommentsHelper

  # checks the privilage of user and creates comment
  def create
    @comment = Comment.create_comment(params, current_user)
  end
end
