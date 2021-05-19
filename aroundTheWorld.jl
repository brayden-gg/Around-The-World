using Plots
using Statistics

NOTCH_COUNT = 9
HALT = 10000

function play(rate::Number, maxChance)
    shots = 0
    notch = 0
    while shots < HALT # if it takes too long just give up
        shots += 1
        while rand() < rate # keep shooting until you miss
            notch += 1

            if notch >= NOTCH_COUNT # check if won
                return shots
            end
        end

        if maxChance > notch # if you want to chance then you get another shot but risk going back to the beginning
            if rand() < rate # first shot 
                while true # you may keep playing
                    notch += 1

                    if notch >= NOTCH_COUNT
                        return shots
                    end

                    if rand() >= rate # essentially a do while loop
                        break
                    end
                end
            else # start over
                notch = 0
            end
        end
    end

    return shots
end

function bestChance(n::Int, rate::Number)
    avgs = []
    notchAvg = [[] for _ in 1:NOTCH_COUNT]
    for bit in 0:NOTCH_COUNT
        chance = vcat(repeat([true], bit), repeat([false], NOTCH_COUNT - bit)) # binary representation of numbers and then convert to boolean array
        
        total = 0
        for i in 1:n
            total += play(rate, maxChance)
        end

        push!(avgs, total/n)
    end
    
    return avgs
end

function freethrowContour(n, rangeOfProbs, lim=40)
 contourf(
    0:NOTCH_COUNT,
    rangeOfProbs, 
    (maxChance, rate) -> mean([play(rate, maxChance) for _ in 1:n]),
    clim=(0, lim), 
    ylabel="Shooting %", 
    xlabel="Chance every time up to y",
    title="Average number of turns required to win Around the World"
    )
    savefig("./aroundTheWorldFrames/heatmap.png")
end

function freethrowHeatmap(n, rangeOfProbs, lim=40)
    numshots(maxChance, rate) = mean([play(rate, maxChance) for _ in 1:n])
    z = reshape([numshots(maxChance, rate) for maxChance in 0:NOTCH_COUNT for rate in rangeOfProbs], (length(rangeOfProbs), NOTCH_COUNT + 1))

    heatmap(
        0:NOTCH_COUNT,
        rangeOfProbs, 
        z,
        clim=(0, lim), 
        ylabel="Shooting Percentage", 
        xlabel="Last Notch Willing to Chance on",
        title="Average number of turns required to win Around the World",
        # size = (1800, 400)
    )
    for i in 1:length(rangeOfProbs)
        numShots = min(z[i, :]...)
        x = indexin(numShots, z[i, :])[1]
        y = rangeOfProbs[i]
        probStep = Float64(rangeOfProbs.step)
        plot!(Shape([x - 1.5, x - .5, x - .5, x - 1.5], [y - probStep/2, y - probStep/2, y + probStep/2, y + probStep/2]), fillcolor=nothing, linecolor="cyan", label=nothing)
    end

    savefig("./heatmap.png")
end

freethrowHeatmap(250000, 0.2:0.025:0.8)
