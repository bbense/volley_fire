defmodule VolleyFire do
  @moduledoc ~S"""
  This module provides a self-scheduling task runner.

  There are two main functions:

  * roll

  The idea is to start all the tasks on the list in
  a wrapper that waits to receive a :start message.
  The controller sends out count :start messages and
  when any of those tasks is finished it sends a start
  message to the next task on the list. There's no evidence
  that doing it this way makes much sense, but it
  was fun to write and shows what is possible on the BEAM.

  * rank

  Does the same thing, but only calls Task.async
  when new slots are available. No :start messages
  are required.

  """

  @doc ~S"""
  Keep count tasks active from the list.

  roll starts all the tasks and puts them into a recieve
  loop waiting for a `:fire` message. As tasks finish, tasks
  in the list are sent `:fire` messages.

  The function returns a pid_list of the final count tasks.
  """
  def roll(function_list, count) do
    pid_list = ready(function_list)
    {fire_now, rolling} = Enum.split(pid_list, count)
    Enum.map(fire_now, &fire(&1))
    await(fire_now, rolling, &fire(&1))
  end

  @doc ~S"""
  Keep count tasks active from the list.

  rank starts count tasks from the list and
  calls `Task.async` as the initial tasks finish
  execution.

  The function returns a pid_list of the final count tasks.
  """
  def rank(function_list, count) do
    {start_now, rolling} = Enum.split(function_list, count)
    pid_list = Enum.map(start_now, &start(&1))
    await(pid_list, rolling, &start(&1))
  end

  # need to return the entire task structure.
  def fire(%Task{pid: pid} = task) do
    send pid, :fire
    task
  end

  def fire(task_list) when is_list(task_list) do
    Enum.map(task_list,fn(task) -> fire(task) end )
  end

  def ready(function_list) when is_list(function_list) do
    Enum.map(function_list, &ready(&1))
  end

  def ready(function) do
    Task.async(fn ->
      receive do
        :fire -> function.()
      end
    end)
  end

  def start(function_list) when is_list(function_list) do
    Enum.map(function_list, &start(&1))
  end

  def start(function) do
    Task.async(function)
  end

  def await(tasks,[],_ready_function) do
    tasks
  end

  def await(tasks, rolling, fire_function) do
     still_running = Enum.filter(tasks, fn(task) -> is_nil(Task.yield(task,0)) end)
     {to_fire, rest} = Enum.split(rolling, Enum.count(tasks) - Enum.count(still_running) )
     now_running = fire_function.(to_fire)
     await(still_running ++ now_running, rest, fire_function)
  end

end
