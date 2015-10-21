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
  def roll(task_list, count) do
    pid_list = start_all(task_list)
    {start_now, rolling} = Enum.split(pid_list,count)
    Enum.map(start_now, &start(&1))


  end

  def start(pid) do

  end

  def start_all(task_list) do

  end

end
