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
    {start_now, rolling} = Enum.split(pid_list, count)
    Enum.map(start_now, &start(&1))
    await(start_now, rolling)
  end

  def start(%Task{pid: pid}) do
    send pid, :start
  end

  def start_all(task_list) do
    Enum.map(task_list, &wait_start(&1))
  end

  def wait_start(task) do
    wait_and_start = fn ->
      receive do
        :start -> task.()
      end
    end
    Task.async(wait_and_start)
  end

  # Be careful, this will receive all messages sent
  # to this process. It will return the first task
  # reply and the list of tasks that came second.
  def await(tasks,[]) do
    tasks
  end

  def await(tasks, rolling) do
    receive do
      message ->
        case Task.find(tasks, message) do
          {_ , task} ->
            List.delete(tasks, task)
            [first | rest ] = rolling
            start(first)
            await(tasks ++ first, rest)
        nil ->
          await(tasks, rolling)
        end
    end
  end


end
