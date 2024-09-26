library(minpack.lm)
library(deSolve)
setwd("C:/Users/Dr. Adamu-REDISSE/OneDrive/Desktop/MMF_Cohort1_2023/R")
Data <- read.csv("Nigeria_COVID19.csv")
library(readxl)
time <- Data$Time
incidence <- Data$incidence
View(Data)
head(Data)

# Plot the observed cases of COVID19 against Time to show the trend of the Disease
plot(time, incidence, type = "l", col = "red", lwd = 3)
title("Cases of COVID19 in Nigeria in 2020")
plot(time, incidence, type = "p", col = "blue", lwd = 3)
title("Cases of COVID19 in Nigeria in 2020")
# Define the differential equation for the SIR model
sir_model <- function(t, state, parms) {
    #t = time, y = parameter/state
    ##Pull state(like compartment) variables from y vector##
    S <- state["S"]
    I <- state["I"]
    R <- state["R"]

    # Define the parameters
    beta  = parms["beta"] #Transmission rate in the completely susceptible population
    gamma = parms["gamma"] #Detection rate in the population
    delta = parms["delta"] #Removal rate from the infected lass
    amp = parms["amp"]
    phi = parms["phi"]
    N     = parms["N"]

    seas<-1+amp*cos(2*pi*(t-phi)/12)
    # SIR Ordinary Differential Equations (ODE)
    dS = - (beta *seas*S * I) / N
    dI = (beta*seas* S* I) / N - (gamma + delta) * I
    dR = (gamma + delta) * I

    # Return the rate of change
    list(c(dS, dI, dR))
}

# Assign initial conditions
initial_state <- c(S = 288600, I = 252, R = 0)

# Parameters
parms <- c(beta = 0.178, delta = 0.10,
           N = 230135262, gamma = 0.432, amp = 1, phi = 10)

# Time points
times <- seq(0, 167, by = 1) #6 months

# Solve the ODE
solution <- ode(y = initial_state, times = times, func = sir_model,
                parms = parms, rtol = 1e-6, atol = 1e-6 )
print(solution)

# Convert the output to a data frame
solution_df <- as.data.frame(solution)

# Print the result
print(solution_df)
#Saving the model
save(sir_model, file = "solution_df")

# To load the model later
load("solution_df")
# Determine the maximum value for the y-axis
y_max <- max(solution_df$S, solution_df$I, solution_df$R,
             na.rm = TRUE)

# Plot the results
plot(solution_df$time, solution_df$I, lwd = 2, type = "l", col = "blue",
     ylim = c(0, 500), xlim = c(0,167),
     ylab = "Number of COVID19 cases",
     xlab = "Time", main = "SIR Model (COVID19 Transmission)")

# Add other compartments to the plot for comparison
#lines(solution_df$time, solution_df$S, lwd = 2, col = "red") # Infected children
lines(solution_df$time, solution_df$I, lwd = 2, col = "green") # Recovered children
lines(solution_df$time, solution_df$R, lwd = 2, col = "blue") # Vaccinated children

# Add a legend
legend("topright", legend = c( "Infected ", "Recovere"),
       col = c( "green", "blue"), lty = 1, cex = 0.8)

##########Curve fitting using our simulated data############

# Loading my data from local drive
library(readxl)
data <- solution_df$I

# Check the structure of the data
str(data)

# Call out columns for 'time', 'Infected', 'Recovered Individual from COVID19'
# Extracting relevant columns
time <- solution_df$time
susceptible_data <- solution_df$S
infected_data <- solution_df$I
recovered_data <- solution_df$R

# Define the SIR COVID19 Model
sir_model <- function(t, state, parms) {
    S <- state["S"]
    I <- state["I"]
    R <- state["R"]

    beta  <- parms["beta"]
    gamma <- parms["gamma"]
    delta <- parms["delta"]
    N     <- parms["N"]

    dS = - (beta *S * I) / N
    dI = (beta* S* I) / N - (gamma + delta) * I
    dR = (gamma + delta) * I

    list(c(dS, dI, dR))
}

# Define the objective function to fit the model
objective_function <- function(parms) {
    # Initial conditions
    initial_state <- c(S = 288600, I = 252, R = 0)

    # Solve the ODE
    solution <- ode(y = initial_state, times = times, func = sir_model, parms = parms, rtol = 1e-6, atol = 1e-6)
    solution_df <- as.data.frame(solution)

    # Calculate residuals for infection and Recovered
    residuals_I <- (solution_df$I - infected_data)^2
    residuals_R <- (solution_df$R - recovered_data)^2

    # Sum of squared residuals
    sum_of_squares <- sum(residuals_I, residuals_R, na.rm = TRUE)

    return(sum_of_squares)

}

# Initial guesses for parameters
initial_guess <- c(beta = 0.178, gamma = 0.004, delta = 0.10,
                   N = 230135262, amp = 1, phi = 10)

# Fit the parameters using optimization
fit <- optim(par = initial_guess, fn = objective_function, method = "L-BFGS-B",
             lower = c(beta = 0, gamma = 0, delta = 0, N = 0
             ),
             upper = c(beta = 1, gamma = 1, delta = 1, N = 1e8
             ), control = list(maxit=10000))
summary(fit)

# View fitted parameters
fitted_parameters <- fit$par
print(fitted_parameters)

# Generate predictions with fitted parameters
solution <- ode(y = initial_state, times = times, func = sir_model, parms = fitted_parameters, rtol = 1e-6, atol = 1e-6)
solution_df <- as.data.frame(solution)
print(solution_df)

#Optimised parameters (beta = 0.178, gamma = 0.004, delta = 0.10,
#N = 230135262, beta = 0.178, gamma = 0.004, sigma = 0.014)

# Determine the maximum value for the y-axis
y_max <- max(solution_df$I,
             na.rm = TRUE)

# Replot the results using the fitted parameters
# Determine the maximum value for the y-axis based on all compartments
y_max <- max(incidence,na.rm = TRUE)

# Plot the observed vs. simulated infected cases
plot(times, infected_data, pch = 16, col = "red", ylim = c(0,3000), xlim = c(0, 167),
     ylab = "Number of COVID19 Cases", xlab = "Time (months)", main = "SIR Model (COVID19 Transmission)")

# Add the simulated infected cases
lines(solution_df$time, solution_df$I, lwd = 2, col = "red", lty = 2)


# Add a legend
legend("topleft", legend = c("Observed Infected", "Simulated Infected"),
       col = c("red", "green"),
       pch = c(16, 16), lty = c(2, 2), cex = 0.8)
