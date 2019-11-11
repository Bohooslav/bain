require 'imba-router'

import {Bible} from './Bible'
import {Profile} from './Profile'

export tag Main
  def render
    <self>
      <Profile route='/profile'>
      <Bible route='/bible'>
