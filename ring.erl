-module(ring).

-export([start/3, start_ring/3]).



start(MaxMessages, NumberOfProcesses, Message) -> 
	Pid = spawn(ring, start_ring, [MaxMessages, NumberOfProcesses, self()]),
	Pid ! {Message, 0},
	handle_message(Pid, MaxMessages).

start_ring(MaxMessages, 0, Anchor) -> handle_message(Anchor, MaxMessages);
start_ring(MaxMessages, NumberOfProcesses, Anchor) -> 	
	handle_message(spawn(ring, start_ring, [MaxMessages, NumberOfProcesses-1, Anchor]), MaxMessages).

handle_message(ReceiverPid, NumberOfMessages) -> 
	receive
		ok -> ReceiverPid! ok, true;		
		{Msg, Hop} -> io:format("~w: ~w -> ~w~n", [self(),Msg,Hop]),
			if 
				Hop < NumberOfMessages -> ReceiverPid ! {Msg, Hop + 1};
				true -> ReceiverPid ! ok
			end,			
			handle_message(ReceiverPid,NumberOfMessages);
		Other -> io:format("Unknown patter: ~w: ~w~n", [self(),Other]),
			handle_message(ReceiverPid, NumberOfMessages)
	end.