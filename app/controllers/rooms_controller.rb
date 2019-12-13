class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :join, :left]
  PUBLIC_ATTRS = Room::REGISTRABLE_ATTRIBUTES + [:id, :male_users_size, :female_users_size, :user_id, :availability]

  def join
    if current_user.role_exists?
      if @room.room_users.where(user_id: current_user.id).exists?
        render status: 500, json: {error: 'すでに参加済です。'}
      else
        if @room.room_users.create(user_id: current_user.id)
          render status: 200, json: {room: room_to_h(@room, current_user)}
        else
          render status: 500
        end
      end
    else
      render status: 401
    end
  end

  def left
    if current_user.role_exists?
      room_user = @room.room_users.find_by(user_id: current_user.id)
      if room_user
        room_user.delete
        render status: 200, json: {room: room_to_h(@room.reload, current_user)}
      else
        render status: 500, json: {error: '参加していません。'}
      end
    else
      render status: 401
    end
  end

  def index
    if current_user.role_exists?
      today = Date.today
      rooms = Room.where('dated_on >= ?', today)
      if !current_user.role_head? && !current_user.role_matchmaker?
        if current_user.birthday
          age = current_user.age
          rooms = rooms.where('min_age <= ?', age).where('max_age >= ?', age)
        else
          rooms = Room.none
        end
      end
      rooms = rooms.map{ |room| room_to_h(room, current_user) }
      render json: {rooms: rooms}
    else
      render status: 401
    end
  end

  def create
    if current_user.role_head? || current_user.role_matchmaker?
      @room = Room.new(room_params)
      @room.user_id = current_user.id
      if @room.save
        render status: 200, json: {room: room_to_h(@room, current_user)}
      else
        render status: 500, json: {errors: @room.errors}
      end
    else
      render status: 401
    end
  end

  def show
    permitted = [:created, :joined, :registrable]
    auth = current_user.role_head? || current_user.role_matchmaker?
    auth ||= permitted.include?(@room.availability(current_user))
    if auth
      room = @room.attributes
      user_attrs = [:nickname, :sex, :age, :marital_status, :role_courtship, :role_matchmaker, :religion, :job, :hobby]
      users = @room.users
      users = users.map{ |user| user_attrs.map { |c| [c, user.try(c)] }.to_h }
      user = @room.user
      user = user_attrs.map { |c| [c, user.try(c)] }.to_h
      render json: {room: room, user: user, users: users}
    else
      render status: 401
    end
  end

  def edit
    if current_user.role_head? || current_user.id == @room.user_id
      room = @room.attributes
      user_attrs = [:nickname, :sex, :age, :marital_status, :role_courtship, :role_matchmaker, :religion, :job, :hobby]
      users = @room.users
      users = users.map{ |user| user_attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {room: room, users: users}
    else
      render status: 401
    end
  end

  def update
    if current_user.role_head? || current_user.id == @room.user_id
      if @room.update(room_params)
        render status: 200, json: {room: room_to_h(@room, current_user)}
      else
        render status: 500, json: {errors: @room.errors}
      end
    else
      render status: 401
    end
  end

private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_to_h(room, user)
    PUBLIC_ATTRS.map{ |c| [c, c == :availability ? room.try(c, user) : room.try(c)] }.to_h
  end

  def room_params
    params.fetch(:room, {}).permit(Room::REGISTRABLE_ATTRIBUTES)
  end
end
