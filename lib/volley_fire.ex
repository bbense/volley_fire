defmodule VolleyFire do
  @moduledoc ~S"""
  This module provides a self-scheduling task runner.

  The idea is to start all the tasks on the list in
  a wrapper that waits to receive a :start message.
  The controller sends out count :start messages and
  when any of those tasks is finished it sends a start
  message to the next task on the list.
  """

  @doc ~S"""
  Keep count tasks active from the list.

  """
  def roll(function_list, count) do
    pid_list = wait_start(function_list)
    {start_now, rolling} = Enum.split(pid_list, count)
    Enum.map(start_now, &start(&1))
    await(start_now, rolling)
  end

  def start(%Task{pid: pid}) do
    send pid, :start
  end

  def start(task_list) when is_list(task_list) do
    Enum.map(task_list,fn(task) -> start(task) end )
  end 

  def wait_start(function_list) when is_list(function_list) do
    Enum.map(function_list, &wait_start(&1))
  end

  def wait_start(function) do
    Task.async(fn ->
      receive do
        :start -> function.()
      end
    end)
  end

  def await(tasks,[]) do
    tasks
  end

  def await(tasks, rolling) do
     still_running = Enum.filter(tasks, fn(task) -> is_nil(Task.yield(task,0)) end)
     {to_start, rest} = Enum.split(rolling, Enum.count(tasks) - Enum.count(still_running) ) 
     start(to_start) 
     await(still_running ++ to_start, rest)
  end

end
