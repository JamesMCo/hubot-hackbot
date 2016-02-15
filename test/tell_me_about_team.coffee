chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot tell me about team X', ->

  describe 'with an existing team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      teamResponse = 
        name: 'My Crazy Team Name'
        members: [ 'U1234', 'U5678' ]
        
      getUserStub = sinon.stub()
      
      getUserStub.withArgs('U1234').returns Promise.resolve
        user: 
          name: 'John'
            
      getUserStub.withArgs('U5678').returns Promise.resolve
        user:
          name: 'Barry'
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        team: teamResponse
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
        getUser: getUserStub
      
      @room.user.say('sarah', '@hubot tell me about team     my crazy team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my crazy team name         '],
        ['hubot', '@sarah "My Crazy Team Name" has 2 members: John, Barry']
      ]
    
    after ->
      @room.destroy()

  describe 'with an unknown team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getTeamStub = sinon.stub().returns Promise.resolve
        statusCode: 404
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team  :smile:').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('smile')

    it 'should tell the user the team does not exist', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team  :smile:'],
        ['hubot', '@sarah Sorry, I can\'t find that team.']
      ]
    
    after ->
      @room.destroy()