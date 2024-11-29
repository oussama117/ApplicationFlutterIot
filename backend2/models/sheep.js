const mongoose = require('mongoose')



const sheepSchema = new mongoose.Schema({

    necklaceID: {
        type: String,
        required: true,
        trim: true,
    },
    age: {

        type: String,
        required: true,
        trim: true,


    },
    race: {
        type: String,
        required: true,
        trim: true,

    },

    healthStatus: {
        type: String,
        required: true,
        trim: true,
    }, weight: {
        type: String,
        required: true,
        min: 0,
    }, vaccinated: {
        type: Boolean,
        default: false,
      },
    },
      {    
          timestamps: true,
      } 



)

const Sheep = mongoose.model("Sheep", sheepSchema);

module.exports = Sheep;