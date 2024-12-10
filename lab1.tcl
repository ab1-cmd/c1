# Simulation parameters setup
set val(stop) 6.0 ; # stopping time of the simulation

# Initialization
set ns [new Simulator]

# Open trace files
set tracefile [open 1.tr w]
$ns trace-all $tracefile

set namfile [open 1.nam w]
$ns namtrace-all $namfile

# Node creation
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Link creation
$ns duplex-link $n1 $n2 1000Kb 60ms DropTail
$ns queue-limit $n1 $n2 14
$ns duplex-link $n2 $n3 500Kb 60ms DropTail
$ns queue-limit $n2 $n3 4
$ns duplex-link-op $n1 $n2 queuePos 0.5
$ns duplex-link-op $n2 $n3 queuePos 0.2

# TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

# FTP application
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 0.2 "$ftp0 start"
$ns at 5.0 "$ftp0 stop"

# Termination procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam 1.nam &
    exit 0
}

$ns at $val(stop) "finish"
$ns run
