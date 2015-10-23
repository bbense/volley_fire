# VolleyFire

**A self scheduling task runner**

This module provides a self-scheduling task runner.

  There are two main functions:

  *** roll ***

  The idea is to start all the tasks on the list in
  a wrapper that waits to receive a :fire message.
  The controller sends out count :fire messages and
  when any of those tasks is finished it sends a :fire
  message to the next task on the list. There's no evidence
  that doing it this way makes much sense, but it
  was fun to write and shows what is possible on the BEAM.

  *** rank ***

  Does the same thing, but only calls Task.async
  when new slots are available. No :fire messages
  are required.



